#!/bin/bash
set -e -u

mkdir -p ${PACKAGES}
cd ${PACKAGES}

echo '*building zlib*'
rm -rf zlib-${ZLIB_VERSION}
tar xf zlib-${ZLIB_VERSION}.tar.gz
cd zlib-${ZLIB_VERSION}
# no longer needed on os x with zlib 1.2.8
#if [ $UNAME = 'Darwin' ]; then
#  patch -N < ${PATCHES}/zlib-configure.diff
#fi
if [ ${PLATFORM} = 'Android' ]; then
   patch -N < ${PATCHES}/android-zlib.diff
fi
./configure --prefix=${BUILD}
make -j$JOBS
make install
cd ${PACKAGES}

check_and_clear_libs
