#!/usr/bin/env bash
set -e -u 

mkdir -p ${PACKAGES}
cd ${PACKAGES}

SPATIALITE_VERSION="4.2.0"

download libspatialite-${SPATIALITE_VERSION}.tar.gz

echoerr 'building spatialite'
rm -rf libspatialite-${SPATIALITE_VERSION}
tar xf libspatialite-${SPATIALITE_VERSION}.tar.gz
cd libspatialite-${SPATIALITE_VERSION}
# need this to statically link from libgdal to avoid 'duplicate symbol _sqlite3_extension_init'
#patch -N src/spatialite/spatialite_init.c ${PATCHES}/libspatial_remove_sqlite3_extension_init.diff

CUSTOM_LIBS=""
if [ -f $BUILD/lib/libgeos.a ]; then
    CUSTOM_LIBS="${CUSTOM_LIBS} -lgeos_c -lgeos"
    BUILD_WITH_GEOS="${BUILD}/bin/geos-config"
fi

if [[ $STDLIB == "libcpp" ]]; then
    CUSTOM_LIBS="$CUSTOM_LIBS -lc++ -lm"
else
    CUSTOM_LIBS="$CUSTOM_LIBS -lstdc++ -lm"
fi

LDFLAGS="${CUSTOM_LIBS}" ./configure ${HOST_ARG} \
--prefix=${BUILD} \
--with-geosconfig=${BUILD}/bin/geos-config \
--enable-static \
--enable-geos \
--disable-freexl \
--disable-shared \
--disable-dependency-tracking \
--disable-mathsql \
--disable-geocallbacks \
--disable-iconv \
--disable-epsg \
--disable-geosadvanced \
--disable-lwgeom \
--disable-libxml2 \
--disable-geopackage \
--disable-gcov \
--disable-examples

$MAKE -j${JOBS}
$MAKE install

cd ${PACKAGES}
