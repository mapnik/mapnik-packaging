#!/bin/bash
set -e -u

mkdir -p ${PACKAGES}
cd ${PACKAGES}

download libgeotiff-${LIBGEOTIFF_VERSION}.tar.gz

echoerr 'building geotiff'
rm -rf libgeotiff-${LIBGEOTIFF_VERSION}
tar xf libgeotiff-${LIBGEOTIFF_VERSION}.tar.gz
cd libgeotiff-${LIBGEOTIFF_VERSION}
./configure --prefix=${BUILD} --enable-static --disable-shared --disable-dependency-tracking \
--with-libtiff=${BUILD} \
--with-jpeg=${BUILD} \
--with-zip=${BUILD} \
--with-proj=${BUILD}
make -j${JOBS}
make install
cd ${PACKAGES}
