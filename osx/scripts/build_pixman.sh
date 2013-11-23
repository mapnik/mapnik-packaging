#!/bin/bash
set -e -u

mkdir -p ${PACKAGES}
cd ${PACKAGES}

echo '*building pixman*'
rm -rf pixman-${PIXMAN_VERSION}
tar xf pixman-${PIXMAN_VERSION}.tar.gz
cd pixman-${PIXMAN_VERSION}
./configure --enable-static --disable-shared \
--disable-dependency-tracking --prefix=${BUILD} \
--disable-mmx
set +e
make -j${JOBS} -i -k
make install -i -k
set -e
cd ${PACKAGES}