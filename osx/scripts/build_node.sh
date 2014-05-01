#!/usr/bin/env bash
set -e -u
set -o pipefail
mkdir -p ${PACKAGES}
cd ${PACKAGES}

if [ ! -f node-v${NODE_VERSION}.tar.gz ]; then
    echo downloading node
    curl -s -S -f -O  http://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}.tar.gz
else
    echo downloading node
fi

echoerr 'building node'
rm -rf node-v${NODE_VERSION}
tar xf node-v${NODE_VERSION}.tar.gz
cd node-v${NODE_VERSION}
LDFLAGS="${STDLIB_LDFLAGS} ${LDFLAGS}"
./configure --prefix=${BUILD} \
 --shared-zlib \
 --shared-zlib-includes=${ZLIB_PATH}/include \
 --shared-zlib-libpath=${ZLIB_PATH}/lib
$MAKE -j${JOBS}
$MAKE install
