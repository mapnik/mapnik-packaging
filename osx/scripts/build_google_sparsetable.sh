#!/bin/bash
set -e -u -x

mkdir -p ${PACKAGES}
cd ${PACKAGES}

download sparsehash-${SPARSEHASH_VERSION}.tar.gz

echoerr 'building sparsehash C++'
rm -rf sparsehash-${SPARSEHASH_VERSION}-${ARCH_NAME}
tar xf sparsehash-${SPARSEHASH_VERSION}.tar.gz
mv sparsehash-${SPARSEHASH_VERSION} sparsehash-${SPARSEHASH_VERSION}-${ARCH_NAME}
cd sparsehash-${SPARSEHASH_VERSION}-${ARCH_NAME}
LDFLAGS="${STDLIB_LDFLAGS} ${LDFLAGS}"
./configure --prefix=${BUILD} ${HOST_ARG} ${CROSS_FLAGS} \
--enable-static --enable-shared \
--disable-debug --with-zlib \
--disable-dependency-tracking
make -j${JOBS}
make install
cd ${PACKAGES}

check_and_clear_libs
