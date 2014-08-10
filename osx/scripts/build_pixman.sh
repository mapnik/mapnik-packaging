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
--disable-mmx --disable-ssse3 --disable-libpng --disable-gtk

# note: --disable-ssse3 is required to fix clang -flto on linux
# LLVM ERROR: Cannot select: intrinsic %llvm.x86.ssse3.pabs.w.128

# set +e is to workaround osx bug in pixman tests: Undefined symbols for architecture x86_64: "_prng_state
set +e
$MAKE -j${JOBS} -i -k
$MAKE install -i -k
set -e
cd ${PACKAGES}

