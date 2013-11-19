set -e 

mkdir -p ${PACKAGES}
cd ${PACKAGES}

# gdal
echo '*building gdal*'

export OLD_CXX=${CXX}
# note: we put ${STDLIB_CXXFLAGS} into CXX instead of CXXFLAGS due to libtool oddity:
# http://stackoverflow.com/questions/16248360/autotools-libtool-link-library-with-libstdc-despite-stdlib-libc-option-pass
export CXX="${CXX} ${STDLIB_CXXFLAGS}"
rm -rf gdal-${GDAL_VERSION}
tar xf gdal-${GDAL_VERSION}.tar.gz
cd gdal-${GDAL_VERSION}
# http://trac.osgeo.org/gdal/wiki/BuildingOnUnixWithMinimizedDrivers
# not bigtiff check will fail…
# fix bigtiff check
patch configure ${PATCHES}/bigtiff_check.diff
if [ $UNAME = 'Darwin' ]; then
  # trick the gdal configure into working on os x
  if [ ! -f "${PACKAGES}/FileGDB_API/lib/libFileGDBAPI.so" ]; then
       touch "${PACKAGES}/FileGDB_API/lib/libFileGDBAPI.so"
  fi
fi
if [ "${CXX11}" = true ]; then
  FGDB_ARGS="--with-fgdb=no"
else
  FGDB_ARGS="--with-fgdb=${PACKAGES}/FileGDB_API/"
fi
export OLD_LDFLAGS=${LDFLAGS}
export LDFLAGS="${STDLIB_LDFLAGS} ${LDFLAGS}"
./configure --prefix=${BUILD} --enable-static --disable-shared \
${FGDB_ARGS} \
--with-libtiff=${BUILD} \
--with-geotiff=${BUILD} \
--with-jpeg=${BUILD} \
--with-png=${BUILD} \
--with-static-proj4=${BUILD} \
--with-sqlite3=${BUILD} \
--with-hide-internal-symbols=no \
--with-spatialite=no \
--with-curl=no \
--with-geos=no \
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

make -j${JOBS}
make install
export LDFLAGS=${OLD_LDFLAGS}
export CXX=${OLD_CXX}
cd ${PACKAGES}

check_and_clear_libs