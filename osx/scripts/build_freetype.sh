#!/bin/bash
set -e -u -x

mkdir -p ${PACKAGES}
cd ${PACKAGES}

download freetype-${FREETYPE_VERSION}.tar.bz2

echoerr 'building freetype'
rm -rf freetype-${FREETYPE_VERSION}
tar xf freetype-${FREETYPE_VERSION}.tar.bz2
cd freetype-${FREETYPE_VERSION}
./configure --prefix=${BUILD} --enable-static --disable-shared ${HOST_ARG} \
 --without-bzip2 \
 --without-png
make -j${JOBS}
make install
cd ${PACKAGES}
