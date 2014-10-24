#!/usr/bin/env bash
set -e -u
set -o pipefail

echoerr 'Building mapnik'
cd ${MAPNIK_SOURCE}
if [[ ${OFFICIAL_RELEASE} != true ]]; then
    git pull
fi

if [ -d ${MAPNIK_BIN_SOURCE} ]; then
  rm -rf ${MAPNIK_BIN_SOURCE}
  rm -f ${MAPNIK_SOURCE}/bindings/python/mapnik/{*.so,*.pyc}
  rm -f ${MAPNIK_SOURCE}/src/libmapnik{*.so,*.dylib,*.a}
  rm -f ${MAPNIK_SOURCE}/tests/cpp_tests/*-bin
  rm -f ${MAPNIK_SOURCE}/benchmark/out/*
  # TODO: https://github.com/mapnik/mapnik/issues/2112
  #$MAKE clean
fi

if [[ "${TRAVIS_COMMIT:-false}" != false ]]; then
   JOBS=2
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
if [[ ${UNAME} = 'Linux' ]]; then
  # NOTE: --no-undefined works with linux linker to ensure that
  # an error is throw if any symbols cannot be resolve for static libs
  # which can happen if their order is incorrect when linked: see lorder | tsort
  # TODO: only apply this to libmapnik (not python bindings) -Wl,--no-undefined
  echo "CUSTOM_LDFLAGS = '${STDLIB_LDFLAGS} ${LDFLAGS} -Wl,-z,origin -Wl,-rpath=\\\$\$ORIGIN'" >> config.py
  echo "OPTIMIZATION = '${OPTIMIZATION}'" >> config.py
else
  echo "CUSTOM_LDFLAGS = '${STDLIB_LDFLAGS} ${LDFLAGS}'" >> config.py
  echo "OPTIMIZATION = 's'" >> config.py
fi
echo "OPTIMIZATION = '${OPTIMIZATION}'" >> config.py
echo "RUNTIME_LINK = 'static'" >> config.py
echo "PATH = '${BUILD}/bin/'" >> config.py
echo "BOOST_INCLUDES = '${BUILD}/include'" >> config.py
echo "BOOST_LIBS = '${BUILD}/lib'" >> config.py
echo "FREETYPE_CONFIG = '${BUILD}/bin/freetype-config'" >> config.py
echo "XML2_CONFIG = '${BUILD}/bin/xml2-config'" >> config.py
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
echo "PATH_REMOVE = '/usr/:/usr/local/'" >> config.py
if [[ ${CXX11} == true ]]; then
    echo "INPUT_PLUGINS = 'csv,gdal,topojson,pgraster,geojson,ogr,postgis,raster,shape,sqlite'" >> config.py
else
    echo "INPUT_PLUGINS = 'csv,gdal,pgraster,geojson,ogr,postgis,raster,shape,sqlite'" >> config.py
fi
echo "FAST = True" >> config.py
echo "DEMO = False" >> config.py
echo "PGSQL2SQLITE = False" >> config.py
echo "SVG2PNG = False" >> config.py
echo "SAMPLE_INPUT_PLUGINS=False" >> config.py
echo "CPP_TESTS=True" >> config.py
echo "BENCHMARK=False" >> config.py
# note, we use FRAMEWORK_PYTHON=False so linking works to custom framework despite use of -isysroot
echo "FRAMEWORK_PYTHON = False" >> config.py
echo "FULL_LIB_PATH = False" >> config.py
echo "ENABLE_SONAME = False" >> config.py
echo "BOOST_PYTHON_LIB = 'boost_python-2.7'" >> config.py
echo "XMLPARSER = 'ptree'" >> config.py

MAPNIK_BINDINGS=""
if [[ "${MINIMAL_MAPNIK:-false}" != false ]]; then
    echo "SVG_RENDERER = False" >> config.py
    echo "CAIRO = False" >> config.py
else
    MAPNIK_BINDINGS="python"
    echo "SVG_RENDERER = True" >> config.py
    echo "CAIRO = True" >> config.py
fi

if [[ $BOOST_ARCH == "arm" ]]; then
    HOST_ARGS='HOST=${ARCH_NAME}'
    echo "BINDINGS = ''" >> config.py
    echo "LINKING = 'static'" >> config.py
    echo "PLUGIN_LINKING = 'static'" >> config.py
    MAPNIK_BINDINGS=""
else
    HOST_ARGS=""
fi

echo "BINDINGS = '${MAPNIK_BINDINGS}'" >> config.py

set_dl_path "${SHARED_LIBRARY_PATH}"
LIBRARY_PATH="${SHARED_LIBRARY_PATH}" ./configure ${HOST_ARGS}
# single job compiles first
for i in {src/json/libmapnik-json.a,src/json/libmapnik-wkt.a,src/css_color_grammar.os,src/expression_grammar.os,src/transform_expression_grammar.os,src/image_filter_types.os}; do
    LIBRARY_PATH="${SHARED_LIBRARY_PATH}" python scons/scons.py -j1 --config=cache --implicit-cache --max-drift=1  $i
done
# then build the rest
LIBRARY_PATH="${SHARED_LIBRARY_PATH}" JOBS=${JOBS} $MAKE
$MAKE install

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
    LIBRARY_PATH="${SHARED_LIBRARY_PATH}" ./configure BINDINGS=python PYTHON=/usr/local/bin/python${i} BOOST_PYTHON_LIB=boost_python-${i}
    LIBRARY_PATH="${SHARED_LIBRARY_PATH}" JOBS=${JOBS} $MAKE
    $MAKE install
    
    for i in {"2.6","2.7"}
    do
      echo "...Updating and building mapnik python bindings for python ${i}"
      rm -f bindings/python/*os
      rm -f bindings/python/mapnik/_mapnik.so
      LIBRARY_PATH="${SHARED_LIBRARY_PATH}" ./configure BINDINGS=python PYTHON=/usr/bin/python${i} BOOST_PYTHON_LIB=boost_python-${i}
      LIBRARY_PATH="${SHARED_LIBRARY_PATH}" JOBS=${JOBS} $MAKE
      $MAKE install
    done
fi

$ROOTDIR/scripts/post_build_fix.sh

unset_dl_path


# remove headers for now
#rm -rf ${MAPNIK_BIN_SOURCE}/include
