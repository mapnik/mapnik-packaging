#!/bin/bash
set -e -u
set -o pipefail
mkdir -p ${PACKAGES}
cd ${PACKAGES}

download libuv-v${LIBUV_VERSION}.tar.gz

echoerr 'building libuv'
rm -rf libuv-${LIBUV_VERSION}
tar xf libuv-v${LIBUV_VERSION}.tar.gz
cd libuv-${LIBUV_VERSION}
./autogen.sh
./configure --prefix=${BUILD} --enable-static --disable-shared ${HOST_ARG} \
  --disable-dependency-tracking \
  --enable-largefile \
  --disable-dtrace
make -j${JOBS}
make install
cd ${PACKAGES}
