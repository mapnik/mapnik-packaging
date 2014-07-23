#!/usr/bin/env bash
set -e -u
set -o pipefail
mkdir -p ${PACKAGES}
cd ${PACKAGES}

download libpng-${LIBPNG_VERSION}.tar.gz

echoerr 'building libpng'
rm -rf libpng-${LIBPNG_VERSION}
tar xf libpng-${LIBPNG_VERSION}.tar.gz
cd libpng-${LIBPNG_VERSION}
# NOTE: C_INCLUDE_PATH is needed for png the gcc -E usage which does not
# seem to respect CFLAGS and will fail to find zlib.h
./configure --prefix=${BUILD} --enable-static --disable-shared ${HOST_ARG} \
  --disable-dependency-tracking \
  --with-zlib-prefix=${ZLIB_PATH}
$MAKE -j${JOBS}
$MAKE install
cd ${PACKAGES}
