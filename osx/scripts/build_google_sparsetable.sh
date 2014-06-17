#!/usr/bin/env bash
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
patch -N ./src/sparsehash/internal/sparsehashtable.h ${PATCHES}/sparsehash_allocator.patch || true
./configure --prefix=${BUILD} ${HOST_ARG} \
--enable-static --disable-shared \
--disable-dependency-tracking
$MAKE -j${JOBS}
$MAKE install
cd ${PACKAGES}

#check_and_clear_libs
