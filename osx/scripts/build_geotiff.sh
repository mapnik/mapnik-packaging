#!/bin/bash
set -e -u
set -o pipefail
mkdir -p ${PACKAGES}
cd ${PACKAGES}

#download libgeotiff-${LIBGEOTIFF_VERSION}.tar.gz

if [ ! -d libgeotiff ]; then
    svn co https://svn.osgeo.org/metacrs/geotiff/trunk/libgeotiff --trust-server-cert --non-interactive
    cd libgeotiff
    ./autogen.sh
else
    cd libgeotiff
    make clean
fi

echoerr 'building geotiff'
#rm -rf libgeotiff-${LIBGEOTIFF_VERSION}
#tar xf libgeotiff-${LIBGEOTIFF_VERSION}.tar.gz
#cd libgeotiff-${LIBGEOTIFF_VERSION}
./configure --prefix=${BUILD} --enable-static --disable-shared --disable-dependency-tracking \
--with-libtiff=${BUILD} \
--with-jpeg=${BUILD} \
--with-zip=${BUILD} \
--with-proj=${BUILD}
make -j${JOBS}
make install
cd ${PACKAGES}
