#!/bin/bash
set -e -u

mkdir -p ${PACKAGES}
cd ${PACKAGES}

download boost_${BOOST_VERSION2}.tar.bz2

if [ $USE_BOOST_TRUNK = 'true' ]; then
    echoerr 'building boost trunk'
    rm -rf boost_trunk-${ARCH_NAME}
    if [ ! -d boost-trunk ]; then
        svn co https://svn.boost.org/svn/boost/trunk boost-trunk
    else
        # takes forever
        cd boost-trunk
        #svn up
        cd ../
    fi
    cp -r boost-trunk boost_trunk-${ARCH_NAME}
    cd boost_trunk-${ARCH_NAME}
else
    echoerr 'building boost'
    rm -rf boost_${BOOST_VERSION2}-${ARCH_NAME}
    tar xjf boost_${BOOST_VERSION2}.tar.bz2
    mv boost_${BOOST_VERSION2} boost_${BOOST_VERSION2}-${ARCH_NAME}
    cd boost_${BOOST_VERSION2}-${ARCH_NAME}
fi

if [ $UNAME = 'Darwin' ]; then
  # patch python build to ensure we do not link boost_python to python
  # https://svn.boost.org/trac/boost/ticket/3930
  patch -N tools/build/v2/tools/python.jam < ${PATCHES}/python_jam.diff
  # https://svn.boost.org/trac/boost/ticket/6686
  if [[ -d /Applications/Xcode.app/Contents/Developer ]]; then
      patch -N tools/build/v2/tools/darwin.jam ${PATCHES}/boost_sdk.diff
  fi
fi

echoerr 'bootstrapping boost'
if [ $PLATFORM = 'Android' ];  then
    echo "using gcc : arm : ${CXX} ;" > user-config.jam
    ./bootstrap.sh --with-toolset=gcc
else
    # way to pass extra flags with cxx, but seems brittle
    #echo "using ${BOOST_TOOLSET} : : ${BOOST_TOOLSET} ${STDLIB_CXXFLAGS} ;" > user-config.jam
    echo "using ${BOOST_TOOLSET} : : `which ${CXX}` ;" > user-config.jam
    ./bootstrap.sh
fi

# HINT: problems with icu configure check?
# cat bin.v2/config.log to see problems

if [ $BOOST_ARCH = "arm" ]; then
    export CROSS_FLAGS=""
    export EXTRA_LIBS_ARGS=""
else
    export CROSS_FLAGS="tools/bcp"
    export EXTRA_LIBS_ARGS="--with-chrono --with-iostreams --with-date_time --with-atomic --with-timer --with-program_options --with-test"
fi

# TODO set address-model ?

# only build with icudata library support on mac
if [ ${BOOST_ARCH} = "x86" ]; then
    export BOOST_LDFLAGS="${STDLIB_LDFLAGS} ${LDFLAGS} -L${BUILD}/lib -licuuc -licui18n -licudata"
    export BOOST_CXXFLAGS="${STDLIB_CXXFLAGS} ${CXXFLAGS} ${ICU_CORE_CPP_FLAGS}"
    export ICU_DETAILS="-sHAVE_ICU=1 -sICU_PATH=${BUILD}"
else
    mv libs/regex/build/has_icu_test.cpp libs/regex/build/has_icu_test.cpp_
    echo '#error' > libs/regex/build/has_icu_test.cpp
    export BOOST_LDFLAGS="${STDLIB_LDFLAGS} ${LDFLAGS}"
    export BOOST_CXXFLAGS="${STDLIB_CXXFLAGS} ${CXXFLAGS} ${ICU_EXTRA_CPP_FLAGS}"
    export ICU_DETAILS=""
fi

if [ $PLATFORM = 'Android' ]; then
    # TODO - fixed in boost 1.55: https://svn.boost.org/trac/boost/changeset/85251
    # workaround libs/filesystem/src/operations.cpp:77:30: fatal error: sys/statvfs.h: No such file or directory
    mkdir -p tmp/sys/
    echo '#include <sys/statfs.h>' > tmp/sys/statvfs.h
    echo '#define statvfs statfs' >> tmp/sys/statvfs.h
    export BOOST_CXXFLAGS="${BOOST_CXXFLAGS} -I./tmp"
    export BOOST_LDFLAGS="${BOOST_LDFLAGS} -L./tmp"
fi


# workaround boost linking problem in trunk
#if [ $STDLIB = "libc++" ]; then
#    export BOOST_LDFLAGS="${BOOST_LDFLAGS} -lc++"
#fi

B2_VERBOSE="-d0"
#B2_VERBOSE="-d2"
echoerr 'compiling boost'
# static libs
./b2 ${CROSS_FLAGS} \
  --prefix=${BUILD} -j${JOBS} ${B2_VERBOSE} \
  --ignore-site-config --user-config=user-config.jam \
  architecture="${BOOST_ARCH}" \
  toolset="${BOOST_TOOLSET}" \
  --with-thread \
  --with-filesystem \
  --disable-filesystem2 \
  --with-system \
  ${EXTRA_LIBS_ARGS} \
  ${ICU_DETAILS} \
  --with-regex \
  link=static,shared \
  variant=release \
  linkflags="${BOOST_LDFLAGS}" \
  cxxflags="${BOOST_CXXFLAGS}" \
  stage install

if [ $UNAME = 'Darwin' ]; then
    otool -L ${BUILD}/lib/*.dylib | grep c++
fi

# clear out shared libs
rm -f ${BUILD}/lib/{*.so,*.dylib}
cd ${PACKAGES}
echoerr 'done compiling boost'
