#!/usr/bin/env bash
set -e -u
set -o pipefail
mkdir -p ${PACKAGES}
cd ${PACKAGES}

download libwebp-${WEBP_VERSION}.tar.gz

echo 'building webp'
rm -rf libwebp-${WEBP_VERSION}
tar xf libwebp-${WEBP_VERSION}.tar.gz
cd libwebp-${WEBP_VERSION}
./configure --prefix=${BUILD} ${HOST_ARG} \
--enable-static --disable-shared --disable-dependency-tracking
$MAKE -j${JOBS}
# TODO - android: cpu.c:17:26: fatal error: cpu-features.h: No such file or directory
$MAKE install
cd ${PACKAGES}