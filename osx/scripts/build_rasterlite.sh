#!/usr/bin/env bash
set -e -u
set -o pipefail
mkdir -p ${PACKAGES}
cd ${PACKAGES}

RASTERLITE_VERSION="1.1g"
download librasterlite-${RASTERLITE_VERSION}.tar.gz

echoerr 'building rasterlite'
export LIBPNG_CFLAGS="-I${BUILD}/include"
export LIBPNG_LIBS="-L${BUILD}/lib -lpng"
export LIBSPATIALITE_CFLAGS="-I${BUILD}/include"
export LIBSPATIALITE_LIBS="-L${BUILD}/lib -lspatialite -lsqlite3 -lm -lz"
rm -rf librasterlite-${RASTERLITE_VERSION}
tar xf librasterlite-${RASTERLITE_VERSION}.tar.gz
cd librasterlite-${RASTERLITE_VERSION}
./configure --prefix=${BUILD} \
 --enable-static \
 --disable-shared \
 ${HOST_ARG} \
 --disable-dependency-tracking

$MAKE -j${JOBS}
$MAKE install
cd ${PACKAGES}
