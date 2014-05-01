#!/usr/bin/env bash
set -e -u
set -o pipefail
mkdir -p ${PACKAGES}
cd ${PACKAGES}


TIFF_LATEST=true

echoerr 'building tiff'

if [[ $TIFF_LATEST == true ]]; then
    #rm -rf libtiff
    if [ ! -d libtiff ]; then
        # NOTE: $MAKE sure this repo is up to date with syncing from
        # https://github.com/OSGeo/gdal/commits/trunk/gdal/frmts/gtiff/libtiff
        git clone --quiet --depth=1 https://github.com/vadz/libtiff.git
        cd libtiff
    else
        cd libtiff
        git pull
        if [[ -f $MAKEFile ]]; then
            $MAKE clean
            $MAKE distclean
        fi
    fi
else
    download tiff-${LIBTIFF_VERSION}.tar.gz
    rm -rf tiff-${LIBTIFF_VERSION}
    tar xf tiff-${LIBTIFF_VERSION}.tar.gz
    cd tiff-${LIBTIFF_VERSION}
fi

if [ $UNAME = 'Darwin' ]; then
    CFLAGS="-DHAVE_APPLE_OPENGL_FRAMEWORK $CFLAGS"
fi

# compare with gdal on status of "experimental features"
# diff -u out/packages/libtiff/libtiff/tif_config.h out/packages/gdal/gdal/frmts/gtiff/libtiff/tif_config.h | grep 'DEFER\|CHUNKY'

# enable-defer-strile-load: https://github.com/OSGeo/gdal/commit/fd3b59bcc8a5f80ca96e2595c189c5904f145049#diff-2a2faa3e24fe7c0ec1fd8a818398bd97
# http://fwarmerdam.blogspot.com/2011/02/mapserver-tiff-overview-performance.html
# enable-chunky-strip-read http://trac.osgeo.org/gdal/ticket/3514
./configure --prefix=${BUILD} \
${HOST_ARG} \
--enable-static --disable-shared \
--disable-dependency-tracking \
--disable-cxx \
--enable-defer-strile-load \
--enable-chunky-strip-read \
--with-jpeg-include-dir=${BUILD}/include \
--with-jpeg-lib-dir=${BUILD}/lib \
--with-zlib-include-dir=${ZLIB_PATH}/include \
--with-zlib-lib-dir=${ZLIB_PATH}/lib \
--disable-lzma --disable-jbig --disable-mdi \
--without-x

$MAKE -j${JOBS}
$MAKE install
cd ${PACKAGES}
