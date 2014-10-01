#!/usr/bin/env bash
set -e -u
set -o pipefail
mkdir -p ${PACKAGES}
cd ${PACKAGES}

# gdal
echoerr 'building gdal'

GDAL_LATEST=false
GDAL_PRE_2x=false

GDAL_SHARED_LIB=true

if [[ $GDAL_SHARED_LIB == true ]]; then
    LIBRARY_ARGS="--disable-static --enable-shared"
else
    LIBRARY_ARGS="--enable-static --disable-shared"
fi

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
        git checkout trunk || true
        git pull || true
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
    else
        git apply ${PATCHES}/gdal_minimal_trunk.diff
    fi
elif [[ ${GDAL_VERSION} == "1.11.1" ]]; then
    patch -N -p1 < ${PATCHES}/gdal-1.11.1-minimal.diff
elif [[ ${GDAL_VERSION} == "1.11.0" ]]; then
    patch -N ogr/ogrsf_frmts/openfilegdb/filegdbtable.cpp ${PATCHES}/gdal-1.11.0-filegdbtable_issue_5464.diff || true
    patch -N -p1 < ${PATCHES}/gdal-1.11.0-minimal.diff || true
    #patch -p0 < ${PATCHES}/temptative_fix_for_5509.patch
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
# note: need -r to delete possible libgdal.1.dylib.dSYM
rm -rf ${BUILD}/lib/libgdal*
rm -f ${SHARED_LIBRARY_PATH}/libgdal*
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
    # TODO - needed anymore?
    #patch -N configure ${PATCHES}/gdal-geos-check.diff || true
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

# note: it might be tempting to build with --without-libtool
# but I find that will only lead to a static libgdal.a and will
# not produce a shared library no matter if --enable-shared is passed

LIBS=$CUSTOM_LIBS ./configure ${HOST_ARG} \
--prefix=${BUILD} \
--with-threads=yes \
${LIBRARY_ARGS} \
${FGDB_ARGS} \
--with-hide-internal-symbols=yes \
--with-libtiff=${BUILD} \
--with-jpeg=${BUILD} \
--with-png=${BUILD} \
--with-static-proj4=${BUILD} \
--with-spatialite=${BUILD_WITH_SPATIALITE} \
--with-geos=${BUILD_WITH_GEOS} \
--with-sqlite3=no \
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
--with-freexl=no \
--with-avx=no \
--with-sse=no

$MAKE -j${JOBS}
$MAKE install
cd ${PACKAGES}


: '

with -flto on os x with: Apple LLVM version 5.1 (clang-503.0.40) (based on LLVM 3.4svn)

perhaps: http://llvm.org/bugs/show_bug.cgi?id=15929 or http://llvm.org/bugs/show_bug.cgi?id=19492

LLVM ERROR: Do not know how to split the result of this operator!

clang: error: linker command failed with exit code 1 (use -v to see invocation)
make[1]: *** [libgdal.la] Error 1

'
#check_and_clear_libs

# build mdb plugin
# http://gis.stackexchange.com/a/76792
# http://www.gdal.org/ogr/drv_mdb.html
# https://trac.osgeo.org/gdal/wiki/ConfigOptions#GDAL_DRIVER_PATH
# http://www.gdal.org/ogr/ogr_drivertut.html
#clang++ -Wall -g ogr/ogrsf_frmts/mdb/ogr*.c* -shared -o ogr_plugins/ogr_MDB.dylib   -Iport -Igcore -Iogr -Iogr/ogrsf_frmts -Iogr/ogrsf_frmts/mdb   -I/System/Library/Frameworks/JavaVM.framework/Headers  -framework JavaVM .libs/libgdal.a -stdlib=libstdc++
#export GDAL_DRIVER_PATH=$(pwd)/ogr_plugins/
#install_name_tool -id ogr_MDB.dylib ogr_plugins/ogr_MDB.dylib
#cp mdb-sqlite-1.0.2/lib/* /Library/Java/Extensions/
