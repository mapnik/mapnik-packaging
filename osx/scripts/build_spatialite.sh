#!/usr/bin/env bash
set -e -u 

mkdir -p ${PACKAGES}
cd ${PACKAGES}

SPATIALITE_VERSION="4.1.1"

download libspatialite-${SPATIALITE_VERSION}.tar.gz

echoerr 'building spatialite'
rm -rf libspatialite-${SPATIALITE_VERSION}
tar xf libspatialite-${SPATIALITE_VERSION}.tar.gz
cd libspatialite-${SPATIALITE_VERSION}
#CFLAGS="-DSQLITE_ENABLE_RTREE=1 $CFLAGS"
patch -N src/shapefiles/validator.c ${PATCHES}/spatialite_validator.diff
# need this since we statically link geos
patch -N configure ${PATCHES}/libspatial_geos_configure.diff
# need this to statically link from libgdal to avoid 'duplicate symbol _sqlite3_extension_init'
patch -N src/spatialite/spatialite_init.c ${PATCHES}/libspatial_remove_sqlite3_extension_init.diff

./configure ${HOST_ARG} \
--prefix=${BUILD} \
--enable-static \
--disable-freexl \
--disable-shared \
--disable-dependency-tracking \
--disable-mathsql \
--disable-geocallbacks \
--disable-iconv \
--disable-epsg \
--disable-geosadvanced \
--disable-geostrunk \
--disable-lwgeom \
--disable-libxml2 \
--disable-geopackage \
--disable-gcov \
--disable-examples

make -j${JOBS}
make install

cd ${PACKAGES}
