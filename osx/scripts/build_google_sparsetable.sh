#!/bin/bash
set -e -u
set -o pipefail
mkdir -p ${PACKAGES}
cd ${PACKAGES}

download sparsehash-${SPARSEHASH_VERSION}.tar.gz

echoerr 'building sparsehash C++'
rm -rf sparsehash-${SPARSEHASH_VERSION}-${ARCH_NAME}
tar xf sparsehash-${SPARSEHASH_VERSION}.tar.gz
mv sparsehash-${SPARSEHASH_VERSION} sparsehash-${SPARSEHASH_VERSION}-${ARCH_NAME}
cd sparsehash-${SPARSEHASH_VERSION}-${ARCH_NAME}
LDFLAGS="${STDLIB_LDFLAGS} ${LDFLAGS}"
./configure --prefix=${BUILD} ${HOST_ARG} \
--enable-static --enable-shared \
--disable-dependency-tracking
make -j${JOBS}
make install
cd ${PACKAGES}

check_and_clear_libs
