#!/bin/bash
set -e -u -x

cd ${MAPNIK_SOURCE}

echo 'Building mapnik mobile'

rm -rf ${MAPNIK_BIN_SOURCE}
rm -f src/libmapnik{*.so,*.dylib,*.a}
rm -f tests/cpp_tests/*-bin
#make clean

if [ "${TRAVIS_COMMIT:-false}" != false ]; then
    if [ $UNAME = 'Darwin' ]; then
      JOBS=1
    else
      JOBS=2
    fi
fi


echo "PREFIX = '${MAPNIK_INSTALL}'" > config.py
echo "DESTDIR = '${MAPNIK_DESTDIR}'" >> config.py
echo "CXX = '${CXX}'" >> config.py
echo "CC = '${CC}'" >> config.py
#echo "CUSTOM_CXXFLAGS = '-gline-tables-only -fno-omit-frame-pointer ${CXXFLAGS}'" >> config.py
if [ ${BOOST_ARCH} = "x86" ]; then
    echo "CUSTOM_CXXFLAGS = '${CXXFLAGS} ${ICU_CORE_CPP_FLAGS}'" >> config.py
else
    echo "CUSTOM_CXXFLAGS = '${CXXFLAGS} ${ICU_EXTRA_CPP_FLAGS}'" >> config.py
fi
echo "CUSTOM_CFLAGS = '${CFLAGS}'" >> config.py
echo "CUSTOM_LDFLAGS = '${STDLIB_LDFLAGS} ${LDFLAGS}'" >> config.py
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

# disable configure checks for all except OS X
if [ -n $HOST_ARG ]; then
    export HOST_ARGS_FOR_IOS='HOST=${ARCH_NAME}'
else
    export HOST_ARGS_FOR_IOS=""
fi

rm -f bindings/python/mapnik/_mapnik.so

./configure \
  PATH_REMOVE="/usr/include" \
  INPUT_PLUGINS=shape,csv,geojson \
  PNG=True \
  JPEG=True \
  BENCHMARK=False \
  LINKING='static' \
  ${HOST_ARGS_FOR_IOS} \
  FULL_LIB_PATH=False \
  BINDINGS='' \
  PLUGIN_LINKING='static' \
  SAMPLE_INPUT_PLUGINS=False \
  SHAPE_MEMORY_MAPPED_FILE=False \
  CAIRO=False \
  TIFF=False \
  WEBP=False \
  PROJ=False \
  SVG2PNG=False \
  SHAPEINDEX=False \
  CPP_TESTS=False \
  DEMO=False \
  SVG_RENDERER=False \
  GRID_RENDERER=False \
  PGSQL2SQLITE=False \
  SYSTEM_FONTS=/System/Library/Fonts
make
make install
