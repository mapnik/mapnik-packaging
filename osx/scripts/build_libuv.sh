#!/usr/bin/env bash
set -e -u
set -o pipefail
mkdir -p ${PACKAGES}
cd ${PACKAGES}

if [ ! -f libuv-v${LIBUV_VERSION}.tar.gz ]; then
    echoerr "downloading libuv: https://github.com/joyent/libuv/archive/v${LIBUV_VERSION}.tar.gz"
    curl -s -S -f -O -L -k https://github.com/joyent/libuv/archive/v${LIBUV_VERSION}.tar.gz
    mv v${LIBUV_VERSION}.tar.gz libuv-v${LIBUV_VERSION}.tar.gz
else
    echoerr "using cached node at libuv-v${LIBUV_VERSION}.tar.gz"
fi

echoerr 'building libuv'
rm -rf libuv-${LIBUV_VERSION}
tar xf libuv-v${LIBUV_VERSION}.tar.gz
cd libuv-${LIBUV_VERSION}

if [[ "${LIBUV_VERSION}" =~ "0.10" ]]; then
    LIBUV_LIBS="-lm -pthread"

    if [[ $UNAME == 'Darwin' ]]; then
        LIBUV_LIBS="${LIBUV_LIBS} \
                    -framework Foundation \
                    -framework CoreServices \
                    -framework ApplicationServices"
    elif [[ $UNAME == 'Linux' ]]; then
        LIBUV_LIBS="${LIBUV_LIBS} -ldl -lrt"
    fi

    echo "prefix=${BUILD}
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: libuv
Version: ${LIBUV_VERSION}
Description: multi-platform support library with a focus on asynchronous I/O.

Libs: -L\${libdir} -luv ${LIBUV_LIBS}
Cflags: -I\${includedir}" > ${BUILD}/lib/pkgconfig/libuv.pc
    $MAKE -j${JOBS}
    cp libuv.a ${BUILD}/lib/
else
    ./autogen.sh
    ./configure --prefix=${BUILD} --enable-static --disable-shared ${HOST_ARG} \
      --disable-dependency-tracking \
      --enable-largefile \
      --disable-dtrace
    $MAKE -j${JOBS}
    $MAKE install
fi
# fix android breakage when building against uv.h
: '
In file included from ../../include/llmr/util/time.hpp:4:
In file included from /Users/dane/projects/mapbox-gl-native/mapnik-packaging/osx/out/build-cpp03-libstdcpp-gcc-arm/include/uv.h:61:
/Users/dane/projects/mapbox-gl-native/mapnik-packaging/osx/out/build-cpp03-libstdcpp-gcc-arm/include/uv-unix.h:41:10: fatal error: 'pthread-fixes.h' file not found
#include "pthread-fixes.h"
'

: '
/Users/travis/build/mapbox/mapbox-gl-native/mapnik-packaging/osx/out/build-cpp11-libstdcpp-gcc-arm/include/uv-unix.h:50:11: fatal error: 
      'uv-darwin.h' file not found
'
cp -r ./include/* $BUILD/include/
cd ${PACKAGES}
