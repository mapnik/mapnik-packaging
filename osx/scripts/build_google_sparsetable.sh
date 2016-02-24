#!/usr/bin/env bash
set -e -u
set -o pipefail
mkdir -p ${PACKAGES}
cd ${PACKAGES}

download sparsehash-${SPARSEHASH_VERSION}.tar.gz

echoerr 'building sparsehash C++'
rm -rf sparsehash-${SPARSEHASH_VERSION}-${ARCH_NAME}
tar xf sparsehash-${SPARSEHASH_VERSION}.tar.gz
mv sparsehash-sparsehash-${SPARSEHASH_VERSION} sparsehash-${SPARSEHASH_VERSION}-${ARCH_NAME}
cd sparsehash-${SPARSEHASH_VERSION}-${ARCH_NAME}
LDFLAGS="${STDLIB_LDFLAGS} ${LDFLAGS}"
./configure --prefix=${BUILD} ${HOST_ARG} \
--enable-static --disable-shared \
--disable-dependency-tracking
$MAKE -j${JOBS}
$MAKE install
cd ${PACKAGES}

#check_and_clear_libs
