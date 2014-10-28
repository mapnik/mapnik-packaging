#!/usr/bin/env bash

if [[ -z "$@" ]]; then
  echo "please pass boost library names like '--with-thread' or one ore more absolute paths to headers that use boost (bcp will search them)"
  exit 1
fi

TARGET_NAMES="$@"

set -e -u
set -o pipefail
mkdir -p ${PACKAGES}
cd ${PACKAGES}

if [[ "${TRAVIS_COMMIT:-false}" != false ]]; then
    if [[ "${CXX#*'clang'}" != "$CXX" ]]; then
        JOBS=6
    else
        JOBS=2
    fi
fi

download boost_${BOOST_VERSION2}.tar.bz2

echoerr 'building boost'
if [[ -d boost_${BOOST_VERSION2}-${ARCH_NAME} ]]; then
  cd boost_${BOOST_VERSION2}-${ARCH_NAME}
  rm -rf bin.v2/ || true
  rm -rf stage/
  # keep bcp around
  #rm -rf dist/
  rm -f project-config.jam*
else
  rm -rf boost_${BOOST_VERSION2}-${ARCH_NAME}
  tar xjf boost_${BOOST_VERSION2}.tar.bz2
  mv boost_${BOOST_VERSION2} boost_${BOOST_VERSION2}-${ARCH_NAME}
  cd boost_${BOOST_VERSION2}-${ARCH_NAME}
fi

# patch to workaround crashes in python.input
# https://github.com/mapnik/mapnik/issues/1968
patch -N libs/python/src/converter/builtin_converters.cpp ${PATCHES}/boost_python_shared_ptr_gil.diff || true

gen_config() {
  echoerr 'generating user-config.jam'
  echo "using ${BOOST_TOOLSET} : : $(which ${CXX})" > user-config.jam
  if [ ${MASON_PLATFORM} = 'Android' ];  then
      patch -N libs/regex/src/fileiter.cpp ${PATCHES}/boost_regex_android_libcxx.diff || true
  fi
  if [[ "${AR:-false}" != false ]] || [[ "${RANLIB:-false}" != false ]]; then
      echo ' : ' >> user-config.jam
      if [[ "${AR:-false}" != false ]]; then
          echo "<archiver>${AR} " >> user-config.jam
      fi
      if [[ "${RANLIB:-false}" != false ]]; then
          echo "<ranlib>${RANLIB} " >> user-config.jam
      fi
  fi

  echo ' ;' >> user-config.jam
}

bootstrap() {
  echoerr 'bootstrapping boost'
  gen_config
  if [[ "${CXX#*'clang++'}" != "$CXX" ]]; then
      ./bootstrap.sh --with-toolset=clang
  else
      ./bootstrap.sh --with-toolset=gcc
  fi
}

# HINT: bootstrap failed? look in bootstrap.log and then debug by building from hand:
# cd .//tools/build/v2/engine/

# HINT: problems with icu configure check?
# cat bin.v2/config.log to see problems

B2_VERBOSE="-d0"
#B2_VERBOSE="-d2"
echoerr 'compiling boost'

if [[ ! -f ./dist/bin/bcp ]] || [[ ${BOOST_ARCH} == "arm" ]]; then
    echoerr 'building bcp'
    # dodge android cross compile problem: ld: unknown option: --start-group
    if [[ ${BOOST_ARCH} == "arm" ]]; then
        echoerr "compiling bjam for HOST ${HOST_PLATFORM}"
        OLD_PLATFORM=${MASON_PLATFORM}
        MASON_CROSS=1 source ${ROOTDIR}/${HOST_PLATFORM}.sh
        bootstrap
        cd tools/bcp
        ../../b2 -j${JOBS} ${B2_VERBOSE}
        cd ../../
        CURRENT_DIR=`pwd`
        MASON_CROSS=1 source ${ROOTDIR}/${OLD_PLATFORM}.sh
        cd ${CURRENT_DIR}
        gen_config
    else
        bootstrap
        cd tools/bcp
        ../../b2 -j${JOBS} ${B2_VERBOSE}
        cd ../../
    fi
else
    bootstrap
fi



write_python_config() {
# usage:
# write_python_config <user-config.jam> <version> <base> <variant>
PYTHON_VERSION=$2
# note: apple pythons need '/System'
PYTHON_BASE=$3
# note: python 3 uses 'm'
PYTHON_VARIANT=$4
if [[ ${UNAME} == 'Darwin' ]]; then
    echo "
      using python
           : ${PYTHON_VERSION} # version
           : ${PYTHON_BASE}/Library/Frameworks/Python.framework/Versions/${PYTHON_VERSION}/bin/python${PYTHON_VERSION}${PYTHON_VARIANT} # cmd-or-prefix
           : ${PYTHON_BASE}/Library/Frameworks/Python.framework/Versions/${PYTHON_VERSION}/include/python${PYTHON_VERSION}${PYTHON_VARIANT} # includes
           : ${PYTHON_BASE}/Library/Frameworks/Python.framework/Versions/${PYTHON_VERSION}/lib/python${PYTHON_VERSION}/config${PYTHON_VARIANT} # a lib actually symlink
           : <toolset>${BOOST_TOOLSET} # condition
           ;
    " >> $1
else
  if [[ ${UNAME} == 'FreeBSD' ]]; then
      echo "
        using python
             : ${PYTHON_VERSION} # version
             : /usr/local/bin/python${PYTHON_VERSION}${PYTHON_VARIANT} # cmd-or-prefix
             : /usr/local/include/python${PYTHON_VERSION} # includes
             : /usr/local/lib/python${PYTHON_VERSION}/config${PYTHON_VARIANT}
             : <toolset>${BOOST_TOOLSET} # condition
             ;
      " >> $1
  else
      echo "
        using python
             : ${PYTHON_VERSION} # version
             : /usr/bin/python${PYTHON_VERSION}${PYTHON_VARIANT} # cmd-or-prefix
             : /usr/include/python${PYTHON_VERSION} # includes
             : /usr/lib/python${PYTHON_VERSION}/config${PYTHON_VARIANT}
             : <toolset>${BOOST_TOOLSET} # condition
             ;
      " >> $1
  fi
fi
}

# if we've requested libraries
if test "${TARGET_NAMES#*'--with'}" != "${TARGET_NAMES}"; then

    # add to user-config.jam if python is requested
    if test "${TARGET_NAMES#*'--with-python'}" != "${TARGET_NAMES}"; then
        cp user-config.jam user-config.jam.bak
        write_python_config user-config.jam "2.7" "/System" ""
    fi

    BOOST_LDFLAGS="${STDLIB_LDFLAGS} ${LDFLAGS}"
    BOOST_CXXFLAGS="${STDLIB_CXXFLAGS} ${CXXFLAGS}"
    ICU_DETAILS="-sHAVE_ICU=0"

    # should we try to link against (presumably static) icu libs?
    if [[ -d ${BUILD}/include/unicode ]]; then
        # only build with icudata library support on mac
        if [ ${BOOST_ARCH} = "x86" ]; then
            BOOST_LDFLAGS="${BOOST_LDFLAGS} -L${BUILD}/lib -licuuc -licui18n -licudata"
            BOOST_CXXFLAGS="${BOOST_CXXFLAGS}  ${ICU_CORE_CPP_FLAGS}"
            ICU_DETAILS="-sHAVE_ICU=1 -sICU_PATH=${BUILD}"
        else
            mv libs/regex/build/has_icu_test.cpp libs/regex/build/has_icu_test.cpp_
            echo '#error' > libs/regex/build/has_icu_test.cpp
            BOOST_CXXFLAGS="${BOOST_CXXFLAGS} ${ICU_EXTRA_CPP_FLAGS}"
        fi
    fi

    if [[ ${MASON_PLATFORM} = 'Android' ]]; then
        # TODO - fixed in boost 1.55: https://svn.boost.org/trac/boost/changeset/85251
        # workaround libs/filesystem/src/operations.cpp:77:30: fatal error: sys/statvfs.h: No such file or directory
        mkdir -p tmp/sys/
        echo '#include <sys/statfs.h>' > tmp/sys/statvfs.h
        echo '#define statvfs statfs' >> tmp/sys/statvfs.h
        BOOST_CXXFLAGS="${BOOST_CXXFLAGS} -I./tmp"
        BOOST_LDFLAGS="${BOOST_LDFLAGS} -L./tmp"
    fi
    ./b2 \
        --prefix=${BUILD} -j${JOBS} ${B2_VERBOSE} \
        --ignore-site-config --user-config=user-config.jam \
        architecture="${BOOST_ARCH}" \
        toolset="${BOOST_TOOLSET}" \
        ${ICU_DETAILS} \
        "$@" \
        link=static \
        variant=release \
        linkflags="${BOOST_LDFLAGS}" \
        cxxflags="${BOOST_CXXFLAGS}" \
        stage install

    # post install python fixes
    if test "${TARGET_NAMES#*'--with-python'}" != "${TARGET_NAMES}"; then
        mv ${BUILD}/lib/libboost_python.a ${BUILD}/lib/libboost_python-2.7.a
    fi

    # clear out shared libs
    #check_and_clear_libs
    echoerr 'done compiling boost'
else
    echoerr 'installing headers with bcp'
    STAGING_DIR=bcp_staging
    mkdir -p ${STAGING_DIR}
    rm -rf ${STAGING_DIR}/*
    for var in "$@"
    do
        ./dist/bin/bcp "${var}" ${STAGING_DIR} 1>/dev/null
    done
    if [[ -d ${STAGING_DIR}/boost/ ]]; then
        du -h -d 0 ${STAGING_DIR}/boost/
        mkdir -p ${BUILD}/include
        # workaround known bugs in BCP where it cannot copy needed headers
        if [[ -d "${STAGING_DIR}/boost/phoenix/" ]]; then
            cp -r boost/phoenix/support/detail ${STAGING_DIR}/boost/phoenix/support/
        fi
        if [[ -d "${STAGING_DIR}/boost/atomic/" ]]; then
            cp -r boost/atomic/detail ${STAGING_DIR}/boost/atomic/
        fi
        if [[ "${BCP_TMP:-false}" != false ]]; then
            echo "copying to ${BCP_TMP}/"
            cp -r ${STAGING_DIR}/boost ${BCP_TMP}/
        else
            echo "not copying to ${BCP_TMP}/"
            cp -r ${STAGING_DIR}/boost ${BUILD}/include/
        fi
    else
        echoerr "WARNING: did not find any boost headers for '$@'"
    fi
fi
