#!/bin/bash
set -e -u

mkdir -p ${PACKAGES}
cd ${PACKAGES}

download tiff-${LIBTIFF_VERSION}.tar.gz

echoerr 'building tiff'
rm -rf tiff-${LIBTIFF_VERSION}
tar xf tiff-${LIBTIFF_VERSION}.tar.gz
cd tiff-${LIBTIFF_VERSION}
export OLD_CFLAGS=$CFLAGS

if [ $UNAME = 'Darwin' ]; then
    export CFLAGS="-DHAVE_APPLE_OPENGL_FRAMEWORK $CFLAGS"
fi

./configure --prefix=${BUILD} \
--enable-static --disable-shared \
--disable-dependency-tracking \
--disable-cxx \
--enable-defer-strile-load \
--with-jpeg-include-dir=${BUILD}/include \
--with-jpeg-lib-dir=${BUILD}/lib \
--with-zlib-include-dir=${BUILD}/include \
--with-zlib-lib-dir=${BUILD}/lib \
--disable-lzma --disable-jbig --disable-mdi \
--without-x

make -j${JOBS}
make install
export CFLAGS=$OLD_CFLAGS
cd ${PACKAGES}
