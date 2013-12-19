#!/bin/bash
set -e -u -x

mkdir -p ${PACKAGES}
cd ${PACKAGES}

download libwebp-${WEBP_VERSION}.tar.gz

echo 'building webp'
rm -rf libwebp-${WEBP_VERSION}
tar xf libwebp-${WEBP_VERSION}.tar.gz
cd libwebp-${WEBP_VERSION}
./configure --prefix=${BUILD} ${HOST_ARG} \
--enable-static --disable-shared --disable-dependency-tracking
make -j${JOBS}
# TODO - android: cpu.c:17:26: fatal error: cpu-features.h: No such file or directory
make install
cd ${PACKAGES}