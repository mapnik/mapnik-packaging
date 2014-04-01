#!/bin/bash
set -e -u
set -o pipefail
mkdir -p ${PACKAGES}
cd ${PACKAGES}

download tiff-${LIBTIFF_VERSION}.tar.gz

echoerr 'building tiff'
rm -rf tiff-${LIBTIFF_VERSION}
tar xf tiff-${LIBTIFF_VERSION}.tar.gz
cd tiff-${LIBTIFF_VERSION}
if [ $UNAME = 'Darwin' ]; then
    CFLAGS="-DHAVE_APPLE_OPENGL_FRAMEWORK $CFLAGS"
fi

./configure --prefix=${BUILD} \
${HOST_ARG} \
--enable-static --disable-shared \
--disable-dependency-tracking \
--disable-cxx \
--enable-defer-strile-load \
--with-jpeg-include-dir=${BUILD}/include \
--with-jpeg-lib-dir=${BUILD}/lib \
--with-zlib-include-dir=${ZLIB_PATH}/include \
--with-zlib-lib-dir=${ZLIB_PATH}/lib \
--disable-lzma --disable-jbig --disable-mdi \
--without-x

make -j${JOBS}
make install
cd ${PACKAGES}
