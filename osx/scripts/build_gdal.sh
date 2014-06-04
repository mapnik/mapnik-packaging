#!/usr/bin/env bash
set -e -u
set -o pipefail
mkdir -p ${PACKAGES}
cd ${PACKAGES}

# gdal
echoerr 'building gdal'

GDAL_LATEST=false
GDAL_PRE_2x=false

if [[ ${GDAL_LATEST} == true ]]; then
    if [ ! -d gdal ]; then
        git clone --quiet https://github.com/OSGeo/gdal.git
        cd gdal/gdal
    else
        cd gdal/gdal
        CUR_NOW=$(date +"%s")
        git diff > latest-${CUR_NOW}
        git checkout .
        git pull || true
    fi
    if [[ ${GDAL_PRE_2x} == true ]]; then
        # before https://github.com/OSGeo/gdal/commit/25cf0d6d573f690c3202886de2d6b9af57d9c2e7
        git checkout 94bd162a965a9b08691a3d0f6b949421ce8fded7
    else
        git checkout trunk
        git pull
    fi
else
    download gdal-${GDAL_VERSION}.tar.gz
    rm -rf gdal-${GDAL_VERSION}
    tar xf gdal-${GDAL_VERSION}.tar.gz
    cd gdal-${GDAL_VERSION}
fi

if [[ ${GDAL_LATEST} == true ]]; then
    if [[ -f GDALmake.opt ]]; then
        $MAKE clean
        $MAKE distclean
    fi
    if [[ ${GDAL_PRE_2x} == true ]]; then
        git apply ${PATCHES}/gdal_minimal.diff
    fi
elif [[ ${GDAL_VERSION} == "1.11.0" ]]; then
    patch -N ogr/ogrsf_frmts/openfilegdb/filegdbtable.cpp ${PATCHES}/gdal-1.11.0-filegdbtable_issue_5464.diff || true
    patch -N -p1 < ${PATCHES}/gdal-1.11.0-minimal.diff || true
fi

# notes to regenerate minimal diff for released version
: '
cd ../
rm -rf gdal-${GDAL_VERSION}
tar xf gdal-${GDAL_VERSION}.tar.gz
cd gdal-${GDAL_VERSION}
git init .
git add ogr/ogrsf_frmts/generic/ogrregisterall.cpp
git add GDALmake.opt.in
git add ogr/ogrsf_frmts/GNUmakefile
git add ogr/ogrsf_frmts/generic/GNUmakefile
git commit -a -m "Add files"
patch -N -p1 < ${PATCHES}/gdal-1.11.0-minimal.diff
git diff > ${PATCHES}/gdal-1.11.0-minimal.diff
'

# purge previous install
rm -f configure.orig configure.rej 
# trouble: cpl_serv.h and cplkeywordparser.h comes from geotiff?
#rm -f ${BUILD}/include/cpl_*
rm -f ${BUILD}/include/gdal*
rm -f ${BUILD}/lib/libgdal*
rm -rf ./.libs
rm -rf ./libgdal.la

# note: we put ${STDLIB_CXXFLAGS} into CXX instead of CXXFLAGS due to libtool oddity:
# http://stackoverflow.com/questions/16248360/autotools-libtool-link-library-with-libstdc-despite-stdlib-libc-option-pass
CXX="${CXX} ${STDLIB_CXXFLAGS} -Wno-pragmas"
# http://trac.osgeo.org/gdal/wiki/BuildingOnUnixWithMinimizedDrivers
# not bigtiff check will fail…
# fix bigtiff check
#patch -N configure ${PATCHES}/bigtiff_check.diff || true
# add ability to link to static geos
patch -N configure ${PATCHES}/gdal-geos-check.diff || true
FGDB_ARGS="--with-fgdb=no"
if [ $UNAME = 'Darwin' ]; then
    # trick the gdal configure into working on os x
    if [ -d "${PACKAGES}/FileGDB_API/" ]; then
        if [ ! -f "${PACKAGES}/FileGDB_API/lib/libFileGDBAPI.so" ]; then
           touch "${PACKAGES}/FileGDB_API/lib/libFileGDBAPI.so"
        fi
        if [ "${CXX11}" = false ]; then
          FGDB_ARGS="--with-fgdb=${PACKAGES}/FileGDB_API/"
        fi
    fi
fi

# warning: unknown warning option '-Wno-pragmas' [-Wunknown-warning-option]
if [[ $UNAME == 'Darwin' ]]; then
    CXXFLAGS=" -Wno-unknown-warning-option $CXXFLAGS"
fi

LDFLAGS="${STDLIB_LDFLAGS} ${LDFLAGS}"
# --with-geotiff=${BUILD} \

BUILD_WITH_SPATIALITE="no"
BUILD_WITH_GEOS="no"
CUSTOM_LIBS=""

if [ -f $BUILD/lib/libspatialite.a ]; then
    CUSTOM_LIBS="${CUSTOM_LIBS} -lgeos_c -lgeos -lsqlite3"
    BUILD_WITH_SPATIALITE="${BUILD}"
fi

if [ -f $BUILD/lib/libgeos.a ]; then
    CUSTOM_LIBS="${CUSTOM_LIBS} -lgeos_c -lgeos"
    BUILD_WITH_GEOS="${BUILD}/bin/geos-config"
fi

if [ -f $BUILD/lib/libtiff.a ]; then
    CUSTOM_LIBS="${CUSTOM_LIBS} -ltiff -ljpeg"
fi

if [ -f $BUILD/lib/libproj.a ]; then
    CUSTOM_LIBS="${CUSTOM_LIBS} -lproj"
fi

if [[ $BUILD_WITH_SPATIALITE != "no" ]] || [[ $BUILD_WITH_GEOS != "no" ]]; then
    if [[ $CXX11 == true ]]; then
        if [[ $STDLIB == "libcpp" ]]; then
            CUSTOM_LIBS="$CUSTOM_LIBS -lc++ -lm"
        else
            CUSTOM_LIBS="$CUSTOM_LIBS -lstdc++ -lm"
        fi
    else
        CUSTOM_LIBS="$CUSTOM_LIBS -lstdc++ -lm"
    fi
fi

LIBS=$CUSTOM_LIBS ./configure ${HOST_ARG} \
--prefix=${BUILD} \
--with-threads=yes \
--enable-static \
--disable-shared \
${FGDB_ARGS} \
--with-libtiff=${BUILD} \
--with-jpeg=${BUILD} \
--with-png=${BUILD} \
--with-static-proj4=${BUILD} \
--with-sqlite3=${BUILD} \
--with-spatialite=${BUILD_WITH_SPATIALITE} \
--with-geos=${BUILD_WITH_GEOS} \
--with-hide-internal-symbols=no \
--with-curl=no \
--with-pcraster=no \
--with-cfitsio=no \
--with-odbc=no \
--with-libkml=no \
--with-pcidsk=no \
--with-jasper=no \
--with-gif=no \
--with-pg=no \
--with-grib=no \
--with-freexl=no

$MAKE -j${JOBS}
$MAKE install
cd ${PACKAGES}

check_and_clear_libs

# build mdb plugin
# http://gis.stackexchange.com/a/76792
# http://www.gdal.org/ogr/drv_mdb.html
# https://trac.osgeo.org/gdal/wiki/ConfigOptions#GDAL_DRIVER_PATH
# http://www.gdal.org/ogr/ogr_drivertut.html
#clang++ -Wall -g ogr/ogrsf_frmts/mdb/ogr*.c* -shared -o ogr_plugins/ogr_MDB.dylib   -Iport -Igcore -Iogr -Iogr/ogrsf_frmts -Iogr/ogrsf_frmts/mdb   -I/System/Library/Frameworks/JavaVM.framework/Headers  -framework JavaVM .libs/libgdal.a -stdlib=libstdc++
#export GDAL_DRIVER_PATH=$(pwd)/ogr_plugins/
#install_name_tool -id ogr_MDB.dylib ogr_plugins/ogr_MDB.dylib
#cp mdb-sqlite-1.0.2/lib/* /Library/Java/Extensions/
