#!/usr/bin/env bash
set -e -u
set -o pipefail
mkdir -p ${PACKAGES}
cd ${PACKAGES}

download protobuf-c-${PROTOBUF_C_VERSION}.tar.gz

echoerr 'building protobuf C'
rm -rf cd protobuf-c-${PROTOBUF_C_VERSION}
tar xf protobuf-c-${PROTOBUF_C_VERSION}.tar.gz
cd protobuf-c-${PROTOBUF_C_VERSION}
./configure --prefix=${BUILD} --enable-static --disable-shared \
--disable-dependency-tracking
make -j${JOBS}
make install
cd ${PACKAGES}