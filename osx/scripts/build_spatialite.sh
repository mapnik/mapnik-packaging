#!/usr/bin/env bash
set -e -u 

mkdir -p ${PACKAGES}
cd ${PACKAGES}

download libspatialite-${SPATIALITE_VERSION}.tar.gz

echoerr 'building spatialite'
rm -rf libspatialite-${SPATIALITE_VERSION}
tar xf libspatialite-${SPATIALITE_VERSION}.tar.gz
cd libspatialite-${SPATIALITE_VERSION}
#CFLAGS="-DSQLITE_ENABLE_RTREE=1 $CFLAGS"
#patch -N src/shapefiles/validator.c ${PATCHES}/spatialite_validator.diff
# need this since we statically link geos
#patch -N configure ${PATCHES}/libspatial_geos_configure.diff
# need this to statically link from libgdal to avoid 'duplicate symbol _sqlite3_extension_init'
#patch -N src/spatialite/spatialite_init.c ${PATCHES}/libspatial_remove_sqlite3_extension_init.diff

LDFLAGS="-lgeos_c -lgeos $LDFLAGS"
if [[ $CXX11 == true ]]; then
    if [[ $STDLIB == "libcpp" ]]; then
        LDFLAGS="$LDFLAGS -lc++ -lm"
    else
        LDFLAGS="$LDFLAGS -lstdc++ -lm"
    fi
else
    LDFLAGS="$LDFLAGS -lstdc++ -lm"
fi
CC=$CXX
./configure ${HOST_ARG} \
--prefix=${BUILD} \
--with-geosconfig="${BUILD}/bin/geos-config" \
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

$MAKE -j${JOBS}
$MAKE install

cd ${PACKAGES}
