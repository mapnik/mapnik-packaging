#!/bin/bash

if [ -z "$@" ]; then
  echo 'please pass boost library names'
  exit 1
fi

set -e -u

mkdir -p ${PACKAGES}
cd ${PACKAGES}

if [ "${TRAVIS_COMMIT:-false}" != false ]; then
    JOBS=2
fi

download boost_${BOOST_VERSION2}.tar.bz2

echoerr 'building boost'
if [[ -d boost_${BOOST_VERSION2}-${ARCH_NAME} ]]; then
  cd boost_${BOOST_VERSION2}-${ARCH_NAME}
  rm -rf bin.v2/ || true
  rm -rf stage/
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

echoerr 'bootstrapping boost'
if [ $PLATFORM = 'Android' ];  then
    echo "using gcc : arm : ${CXX} ;" > user-config.jam
    ./bootstrap.sh --with-toolset=gcc
else
    echo "using ${BOOST_TOOLSET} : : `which ${CXX}` ;" > user-config.jam
    ./bootstrap.sh --with-toolset=${BOOST_TOOLSET}
fi

# HINT: problems with icu configure check?
# cat bin.v2/config.log to see problems

if [ $BOOST_ARCH = "arm" ]; then
    CROSS_FLAGS=""
else
    CROSS_FLAGS="tools/bcp"
fi

# TODO set address-model ?

# only build with icudata library support on mac
if [ ${BOOST_ARCH} = "x86" ]; then
    BOOST_LDFLAGS="${STDLIB_LDFLAGS} ${LDFLAGS} -L${BUILD}/lib -licuuc -licui18n -licudata"
    BOOST_CXXFLAGS="${STDLIB_CXXFLAGS} ${CXXFLAGS} ${ICU_CORE_CPP_FLAGS}"
    ICU_DETAILS="-sHAVE_ICU=1 -sICU_PATH=${BUILD}"
else
    mv libs/regex/build/has_icu_test.cpp libs/regex/build/has_icu_test.cpp_
    echo '#error' > libs/regex/build/has_icu_test.cpp
    BOOST_LDFLAGS="${STDLIB_LDFLAGS} ${LDFLAGS}"
    BOOST_CXXFLAGS="${STDLIB_CXXFLAGS} ${CXXFLAGS} ${ICU_EXTRA_CPP_FLAGS}"
    ICU_DETAILS=""
fi

if [ $PLATFORM = 'Android' ]; then
    # TODO - fixed in boost 1.55: https://svn.boost.org/trac/boost/changeset/85251
    # workaround libs/filesystem/src/operations.cpp:77:30: fatal error: sys/statvfs.h: No such file or directory
    mkdir -p tmp/sys/
    echo '#include <sys/statfs.h>' > tmp/sys/statvfs.h
    echo '#define statvfs statfs' >> tmp/sys/statvfs.h
    BOOST_CXXFLAGS="${BOOST_CXXFLAGS} -I./tmp"
    BOOST_LDFLAGS="${BOOST_LDFLAGS} -L./tmp"
fi

B2_VERBOSE="-d0"
#B2_VERBOSE="-d2"
echoerr 'compiling boost'
# static libs
./b2 ${CROSS_FLAGS} \
  --prefix=${BUILD} -j${JOBS} ${B2_VERBOSE} \
  --ignore-site-config --user-config=user-config.jam \
  architecture="${BOOST_ARCH}" \
  toolset="${BOOST_TOOLSET}" \
  ${ICU_DETAILS} \
  "$@" \
  link=static,shared \
  variant=release \
  linkflags="${BOOST_LDFLAGS}" \
  cxxflags="${BOOST_CXXFLAGS}" \
  stage install

# clear out shared libs
check_and_clear_libs
echoerr 'done compiling boost'
