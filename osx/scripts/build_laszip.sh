#!/usr/bin/env bash
set -e -u
set -o pipefail
mkdir -p ${PACKAGES}
cd ${PACKAGES}

echoerr 'building laszip'

if [ ! -f v2.2.0.tar.gz ]; then
    ${SYSTEM_CURL} -s -S -f -O -L https://github.com/LASzip/LASzip/archive/v2.2.0.tar.gz
fi

rm -rf LASzip-2.2.0
tar xf v2.2.0.tar.gz
cd LASzip-2.2.0
mkdir build
cd build
cmake ../ \
-DCMAKE_INSTALL_PREFIX=${BUILD} \
-DBUILD_STATIC=ON
$MAKE -j${JOBS} VERBOSE=1
$MAKE install

cd ${PACKAGES}
