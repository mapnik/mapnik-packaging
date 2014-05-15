#!/usr/bin/env bash
set -e -u
set -o pipefail
mkdir -p ${PACKAGES}
cd ${PACKAGES}

echoerr 'building liblas'

LIBLAS_LATEST=false

if [[ $LIBLAS_LATEST ]]; then
    rm -rf libLAS
    git clone --depth 1 git@github.com:libLAS/libLAS.git
    cd libLAS
else
    download libLAS-${LIBLAS_VERSION}.tar.gz
    rm -rf libLAS-${LIBLAS_VERSION}
    tar xf libLAS-${LIBLAS_VERSION}.tar.gz
    cd libLAS-${LIBLAS_VERSION}
    # workaround https://gist.github.com/hobu/8477865
    patch -N src/gt_wkt_srs.cpp ${PATCHES}/liblas-gt.diff || true
fi

# Below two patches are to enable linking against a static libgdal.a
# https://github.com/libLAS/libLAS/issues/33
# workaround for bogus library path detection
patch -N cmake/modules/FindGDAL.cmake ${PATCHES}/liblas-find-gdal.diff || true
# workaround for duplicate symbols:
: '
duplicate symbol _GTIFGetOGISDefn in:
    CMakeFiles/las.dir/gt_wkt_srs.cpp.o
    /Users/dane/projects/mapnik-packaging/osx/out/build-cpp03-libstdcpp-x86_64/lib/libgdal.a(gt_wkt_srs.o)

'
patch -N src/CmakeLists.txt ${PATCHES}/liblas-skip-gt_wkt_srs.diff || true

rm -rf build
mkdir -p build
cd build

# purge previous install
rm -rf ${BUILD}/include/liblas
rm -f ${BUILD}/lib/liblas.*

# oddly LDFLAGS rather than LINK_FLAGS are respected
# by liblas CMAKE environment
GDAL_LIBS=$(gdal-config --libs)
GDAL_LIBS="$GDAL_LIBS $(gdal-config --dep-libs)"
LDFLAGS="$GDAL_LIBS $LDFLAGS ${STDLIB_LDFLAGS}"

cmake ../ -DCMAKE_INSTALL_PREFIX=${BUILD} \
  -DWITH_GEOTIFF=ON \
  -DWITH_GDAL=ON \
  -DWITH_LASZIP=ON \
  -DLASZIP_INCLUDE_DIR=${BUILD}/include \
  -DWITH_STATIC_LASZIP=ON \
  -DBoost_NO_SYSTEM_PATHS=ON \
  -DBoost_USE_STATIC_LIBS=ON \
  -DBoost_USE_MULTITHREADED=ON \
  -DCMAKE_INCLUDE_PATH=${BUILD}/include \
  -DCMAKE_LIBRARY_PATH=${BUILD}/lib \
  -DCMAKE_BUILD_TYPE=Release
$MAKE -j${JOBS} VERBOSE=1
$MAKE install

check_and_clear_libs

#  -DCMAKE_SHARED_LINKER_FLAGS="$GDAL_LIBS"

cd ${PACKAGES}
