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
cd ${PACKAGES}
