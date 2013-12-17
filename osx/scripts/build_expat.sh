#!/bin/bash
set -e -u

mkdir -p ${PACKAGES}
cd ${PACKAGES}

# expat for gdal to avoid linking against system expat in /usr/lib
echoerr 'building expat'
rm -rf expat-${EXPAT_VERSION}
tar xf expat-${EXPAT_VERSION}.tar.gz
cd expat-${EXPAT_VERSION}
./configure --prefix=${BUILD} --enable-static --disable-shared
make -j${JOBS}
make install
cd ${PACKAGES}
