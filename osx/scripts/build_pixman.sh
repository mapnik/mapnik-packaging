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

: '
On linux with clang-3.4 and -flto:

perhaps: http://llvm.org/bugs/show_bug.cgi?id=13000

LLVM ERROR: Cannot select: intrinsic %llvm.x86.ssse3.pabs.w.128
clang: error: linker command failed with exit code 1 (use -v to see invocation)

'