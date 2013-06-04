set -e 
cd ${MAPNIK_SOURCE}

echo 'Building mapnik minimal ios'

rm -rf ${MAPNIK_BIN_SOURCE}
rm -f src/libmapnik* # ensure both .a and .dylib are cleared
rm -f tests/cpp_tests/*-bin
make clean

echo "PREFIX = '${MAPNIK_INSTALL}'" > config.py
echo "DESTDIR = '${MAPNIK_DESTDIR}'" >> config.py
echo "CXX = '${CXX}'" >> config.py
echo "CC = '${CC}'" >> config.py
#echo "CUSTOM_CXXFLAGS = '-gline-tables-only ${CXXFLAGS}'" >> config.py
echo "CUSTOM_CXXFLAGS = '${CXXFLAGS}'" >> config.py
echo "CUSTOM_CFLAGS = '${CFLAGS}'" >> config.py
echo "CUSTOM_LDFLAGS = '${LDFLAGS}'" >> config.py
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
if [ $BOOST_ARCH = "x86" ]; then
    export HOST_ARGS_FOR_IOS=""
else
    export HOST_ARGS_FOR_IOS='HOST=${ARCH_NAME}'
fi

rm -f bindings/python/mapnik/_mapnik.so

./configure \
  PATH_REMOVE="/usr/include" \
  INPUT_PLUGINS=shape,csv,geojson,sqlite \
  PNG=True \
  JPEG=True \
  BENCHMARK=False \
  LINKING='static' \
  $HOST_ARGS_FOR_IOS \
  FULL_LIB_PATH=False \
  BINDINGS='' \
  INPUT_PLUGINS=shape,csv,geojson,sqlite \
  PLUGIN_LINKING='static' \
  SAMPLE_INPUT_PLUGINS=False \
  SHAPE_MEMORY_MAPPED_FILE=False \
  CAIRO=False \
  TIFF=False \
  PROJ=False \
  SVG2PNG=False \
  SHAPEINDEX=False \
  CPP_TESTS=False \
  DEMO=False \
  SVG_RENDERER=False \
  PGSQL2SQLITE=False \
  SYSTEM_FONTS=/System/Library/Fonts
make
make install
