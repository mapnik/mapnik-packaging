#!/usr/bin/env bash
set -e -u
set -o pipefail
mkdir -p ${PACKAGES}
cd ${PACKAGES}

if [ ! -f libuv-v${LIBUV_VERSION}.tar.gz ]; then
    echoerr "downloading libuv: https://github.com/joyent/libuv/archive/v${LIBUV_VERSION}.tar.gz"
    curl -s -S -f -O -L https://github.com/joyent/libuv/archive/v${LIBUV_VERSION}.tar.gz
    mv v${LIBUV_VERSION}.tar.gz libuv-v${LIBUV_VERSION}.tar.gz
else
    echoerr "using cached node at libuv-v${LIBUV_VERSION}.tar.gz"
fi

echoerr 'building libuv'
rm -rf libuv-${LIBUV_VERSION}
tar xf libuv-v${LIBUV_VERSION}.tar.gz
cd libuv-${LIBUV_VERSION}
./autogen.sh
./configure --prefix=${BUILD} --enable-static --disable-shared ${HOST_ARG} \
  --disable-dependency-tracking \
  --enable-largefile \
  --disable-dtrace
$MAKE -j${JOBS}
$MAKE install
# fix android breakage when building against uv.h
: '
In file included from ../../include/llmr/util/time.hpp:4:
In file included from /Users/dane/projects/mapbox-gl-native/mapnik-packaging/osx/out/build-cpp03-libstdcpp-gcc-arm/include/uv.h:61:
/Users/dane/projects/mapbox-gl-native/mapnik-packaging/osx/out/build-cpp03-libstdcpp-gcc-arm/include/uv-unix.h:41:10: fatal error: 'pthread-fixes.h' file not found
#include "pthread-fixes.h"
'
cp ./include/pthread-fixes.h $BUILD/include/
cd ${PACKAGES}
