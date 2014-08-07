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
    if [[ $UNAME == 'Darwin' ]]; then
      JOBS=2
    else
      JOBS=6
    fi
fi

download boost_${BOOST_VERSION2}.tar.bz2

echoerr 'building boost'
if [[ -d boost_${BOOST_VERSION2}-${ARCH_NAME} ]]; then
  cd boost_${BOOST_VERSION2}-${ARCH_NAME}
  rm -rf bin.v2/ || true
  rm -rf stage/
  rm -rf dist/
  rm -f project-config.jam*
else
  rm -rf boost_${BOOST_VERSION2}-${ARCH_NAME}
  tar xjf boost_${BOOST_VERSION2}.tar.bz2
  mv boost_${BOOST_VERSION2} boost_${BOOST_VERSION2}-${ARCH_NAME}
  cd boost_${BOOST_VERSION2}-${ARCH_NAME}
fi

if [ $UNAME = 'Darwin' ]; then
  # patch python build to ensure we do not link boost_python to python
  # https://svn.boost.org/trac/boost/ticket/3930
  patch -N tools/build/v2/tools/python.jam ${PATCHES}/python_jam.diff || true
  # https://svn.boost.org/trac/boost/ticket/6686
  if [[ -d /Applications/Xcode.app/Contents/Developer ]]; then
      patch -N tools/build/v2/tools/darwin.jam ${PATCHES}/boost_sdk.diff || true
  fi
fi

# patch to workaround crashes in python.input
# https://github.com/mapnik/mapnik/issues/1968
patch -N libs/python/src/converter/builtin_converters.cpp ${PATCHES}/boost_python_shared_ptr_gil.diff || true

# Patches boost::atomic for LLVM 3.4 as it is used on OS X 10.9 with Xcode 5.1
# https://github.com/Homebrew/homebrew/issues/27396
# https://github.com/Homebrew/homebrew/pull/27436
patch -N boost/atomic/detail/cas128strong.hpp ${PATCHES}/boost_cas128strong.diff || true
patch -N boost/atomic/detail/gcc-atomic.hpp ${PATCHES}/boost_gcc-atomic.diff || true

BOOST_TOOLSET="gcc"
if [[ $UNAME == 'Darwin' ]]; then
  BOOST_TOOLSET="clang"
fi


gen_config() {
  echoerr 'generating user-config.jam'
  echo "using ${BOOST_TOOLSET} : : $(which ${CXX})" > user-config.jam
  if [ $PLATFORM = 'Android' ];  then
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

if [[ ! -f ./dist/bin/bcp ]]; then
    echoerr 'building bcp'
    # dodge android cross compile problem: ld: unknown option: --start-group
    if [[ ${BOOST_ARCH} == "arm" ]]; then
        echoerr "compiling bjam for HOST ${HOST_PLATFORM}"
        OLD_PLATFORM=${PLATFORM}
        source ${ROOTDIR}/${HOST_PLATFORM}.sh
        bootstrap
        cd tools/bcp
        ../../b2 -j${JOBS} ${B2_VERBOSE}
        cd ../../
        CURRENT_DIR=`pwd`
        source ${ROOTDIR}/${OLD_PLATFORM}.sh
        cd ${CURRENT_DIR}
        gen_config
    else
        bootstrap
        cd tools/bcp
        ../../b2 -j${JOBS} ${B2_VERBOSE}
        cd ../../
    fi
fi

# if we've requested libraries
if test "${TARGET_NAMES#*'--with'}" != "${TARGET_NAMES}"; then

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

    if [[ ${PLATFORM} = 'Android' ]]; then
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
        cp -r ${STAGING_DIR}/boost ${BUILD}/include/
    else
        echoerr "WARNING: did not find any boost headers for '$@'"
    fi
fi
