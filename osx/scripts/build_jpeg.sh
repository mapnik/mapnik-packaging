#!/bin/bash
set -e -u -x

mkdir -p ${PACKAGES}
cd ${PACKAGES}

download jpegsrc.v${JPEG_VERSION}.tar.gz

echoerr 'building jpeg'
rm -rf jpeg-${JPEG_VERSION}
tar xf jpegsrc.v${JPEG_VERSION}.tar.gz
cd jpeg-${JPEG_VERSION}
./configure --prefix=${BUILD} --enable-static --disable-shared ${HOST_ARG} --disable-dependency-tracking
make -j${JOBS}
make install
cd ${PACKAGES}
