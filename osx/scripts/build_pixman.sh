#!/usr/bin/env bash
set -e -u
set -o pipefail
mkdir -p ${PACKAGES}
cd ${PACKAGES}

download pixman-${PIXMAN_VERSION}.tar.gz

echoerr 'building pixman'
rm -rf pixman-${PIXMAN_VERSION}
tar xf pixman-${PIXMAN_VERSION}.tar.gz
cd pixman-${PIXMAN_VERSION}
./configure --enable-static --disable-shared \
--disable-dependency-tracking --prefix=${BUILD} \
--disable-mmx
set +e
$MAKE -j${JOBS} -i -k
$MAKE install -i -k
set -e
cd ${PACKAGES}