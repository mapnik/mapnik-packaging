#!/bin/bash
set -e -u
set -o pipefail

echoerr 'Building mapnik'

cd ${MAPNIK_SOURCE}
if [ -d ${MAPNIK_BIN_SOURCE} ]; then
  rm -rf ${MAPNIK_BIN_SOURCE}
  rm -f ${MAPNIK_BIN_SOURCE}/src/libmapnik{*.so,*.dylib,*.a}
  rm -f ${MAPNIK_BIN_SOURCE}/tests/cpp_tests/*-bin
  # TODO: https://github.com/mapnik/mapnik/issues/2112
  #make clean
fi

if [[ "${TRAVIS_COMMIT:-false}" != false ]]; then
    if [[ $UNAME == 'Darwin' ]]; then
      JOBS=1
    else
      JOBS=2
    fi
fi

echo "PREFIX = '${MAPNIK_INSTALL}'" > config.py
echo "DESTDIR = '${MAPNIK_DESTDIR}'" >> config.py
echo "CXX = '${CXX}'" >> config.py
echo "CC = '${CC}'" >> config.py
if [ ${BOOST_ARCH} = "x86" ]; then
    echo "CUSTOM_CXXFLAGS = '${CXXFLAGS} ${ICU_CORE_CPP_FLAGS}'" >> config.py
else
    echo "CUSTOM_CXXFLAGS = '${CXXFLAGS} ${ICU_EXTRA_CPP_FLAGS}'" >> config.py
fi
echo "CUSTOM_CFLAGS = '${CFLAGS}'" >> config.py
if [ $UNAME = 'Linux' ]; then
  # NOTE: --no-undefined works with linux linker to ensure that
  # an error is throw if any symbols cannot be resolve for static libs
  # which can happen if their order is incorrect when linked: see lorder | tsort
  # TODO: only apply this to libmapnik (not python bindings) -Wl,--no-undefined
  echo "CUSTOM_LDFLAGS = '${STDLIB_LDFLAGS} ${LDFLAGS}'" >> config.py
else
  echo "CUSTOM_LDFLAGS = '${STDLIB_LDFLAGS} ${LDFLAGS}'" >> config.py
fi
echo "OPTIMIZATION = '${OPTIMIZATION}'" >> config.py
echo "RUNTIME_LINK = 'static'" >> config.py
echo "PATH = '${BUILD}/bin/'" >> config.py
echo "BOOST_INCLUDES = '${BUILD}/include'" >> config.py
echo "BOOST_LIBS = '${BUILD}/lib'" >> config.py
echo "FREETYPE_CONFIG = '${BUILD}/bin/freetype-config'" >> config.py
echo "ICU_INCLUDES = '${BUILD}/include'" >> config.py
echo "ICU_LIBS = '${BUILD}/lib'" >> config.py
echo "PNG_INCLUDES = '${BUILD}/include'" >> config.py
echo "PNG_LIBS = '${BUILD}/lib'" >> config.py
echo "JPEG_INCLUDES = '${BUILD}/include'" >> config.py
echo "JPEG_LIBS = '${BUILD}/lib'" >> config.py
echo "TIFF_INCLUDES = '${BUILD}/include'" >> config.py
echo "TIFF_LIBS = '${BUILD}/lib'" >> config.py
echo "SQLITE_INCLUDES = '${BUILD}/include'" >> config.py
echo "SQLITE_LIBS = '${BUILD}/lib'" >> config.py
echo "PROJ_INCLUDES = '${BUILD}/include'" >> config.py
echo "PROJ_LIBS = '${BUILD}/lib'" >> config.py
echo "CAIRO_INCLUDES = '${BUILD}/include'" >> config.py
echo "CAIRO_LIBS = '${BUILD}/lib'" >> config.py
echo "PYTHON_PREFIX = '${MAPNIK_INSTALL}'" >> config.py

./configure \
  PATH_REMOVE="/usr/:/usr/local/" \
  BINDINGS='python' \
  INPUT_PLUGINS='csv,gdal,geojson,ogr,osm,postgis,raster,shape,sqlite' \
  DEMO=True \
  SVG_RENDERER=true \
  CAIRO=True \
  PGSQL2SQLITE=False \
  SVG2PNG=False \
  FRAMEWORK_PYTHON=False \
  FULL_LIB_PATH=False \
  ENABLE_SONAME=False \
  BOOST_PYTHON_LIB=boost_python-2.7 || cat config.log
# note, we use FRAMEWORK_PYTHON=False so linking works to custom framework despite use of -isysroot
JOBS=${JOBS} make
make install

# https://github.com/mapnik/mapnik/issues/1901#issuecomment-18920366
export PYTHONPATH=""

echo "
from os import path
mapnik_data_dir = path.normpath(path.join(__file__,'../../../../../share/mapnik/'))
env = {
    'ICU_DATA': path.join(mapnik_data_dir, 'icu'),
    'GDAL_DATA': path.join(mapnik_data_dir, 'gdal'),
    'PROJ_LIB': path.join(mapnik_data_dir, 'proj')
}
" > bindings/python/mapnik/mapnik_settings.py

if [[ ${OFFICIAL_RELEASE} == true ]]; then
    # python versions
    export i="3.3"
    echo "...Updating and building mapnik python bindings for python ${i}"
    rm -f bindings/python/*os
    rm -f bindings/python/mapnik/_mapnik.so
    ./configure BINDINGS=python PYTHON=/usr/local/bin/python${i} BOOST_PYTHON_LIB=boost_python-${i}
    JOBS=${JOBS} make
    make install
    
    for i in {"2.6","2.7"}
    do
      echo "...Updating and building mapnik python bindings for python ${i}"
      rm -f bindings/python/*os
      rm -f bindings/python/mapnik/_mapnik.so
      ./configure BINDINGS=python PYTHON=/usr/bin/python${i} BOOST_PYTHON_LIB=boost_python-${i}
      JOBS=${JOBS} make
      make install
    done
fi

# remove headers for now
#rm -rf ${MAPNIK_BIN_SOURCE}/include
