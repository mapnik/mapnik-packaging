#!/bin/bash
set -e -u

mkdir -p ${PACKAGES}
cd ${PACKAGES}

download libjpeg-turbo-${JPEG_TURBO_VERSION}.tar.gz

ensure_nasm

echoerr 'building jpeg turbo'
rm -rf libjpeg-turbo-${JPEG_TURBO_VERSION}
tar xf libjpeg-turbo-${JPEG_TURBO_VERSION}.tar.gz
cd libjpeg-turbo-${JPEG_TURBO_VERSION}
autoreconf -fiv
./configure --prefix=${BUILD} ${HOST_ARG} \
  NASM="${BUILD_TOOLS_ROOT}/bin/nasm" \
  --enable-static --disable-shared  \
  --with-jpeg8 \
  --disable-dependency-tracking
make -j1
make install
cd ${PACKAGES}
