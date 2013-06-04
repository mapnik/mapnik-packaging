set -e 
cd ${MAPNIK_SOURCE}

echo 'Building mapnik'

rm -rf ${MAPNIK_BIN_SOURCE}
rm -f src/libmapnik* # ensure both .a and .dylib are cleared
rm -f tests/cpp_tests/*-bin
make clean

echo "PREFIX = '${MAPNIK_INSTALL}'" > config.py
echo "DESTDIR = '${MAPNIK_DESTDIR}'" >> config.py
echo "CXX = '${CXX}'" >> config.py
echo "CC = '${CC}'" >> config.py
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
  PATH_REMOVE="/usr/include" \
  BINDINGS='' \
  INPUT_PLUGINS='csv,gdal,geojson,ogr,osm,postgis,raster,shape,sqlite' \
  CAIRO=True \
  JOBS=6 \
  DEMO=True \
  PGSQL2SQLITE=True \
  SVG2PNG=False \
  FRAMEWORK_PYTHON=False \
  BOOST_PYTHON_LIB=boost_python-2.7
# note, we use FRAMEWORK_PYTHON=False so linking works to custom framework despite use of -isysroot
make
make install

# python versions
export i="3.3"
echo "...Updating and building mapnik python bindings for python ${i}"
rm -f bindings/python/*os
rm -f bindings/python/mapnik/_mapnik.so
./configure BINDINGS=python PYTHON=/usr/local/bin/python${i} BOOST_PYTHON_LIB=boost_python-${i}
make
make install

for i in {"2.6","2.7"}
do
  echo "...Updating and building mapnik python bindings for python ${i}"
  rm -f bindings/python/*os
  rm -f bindings/python/mapnik/_mapnik.so
  ./configure BINDINGS=python PYTHON=/usr/bin/python${i} BOOST_PYTHON_LIB=boost_python-${i}
  make
  make install
done

# write mapnik_settings.py
# TODO - set up local symlinks so that this does not break make test-local?
# https://github.com/mapnik/mapnik/issues/1892
echo "
from os import path
mapnik_data_dir = path.normpath(path.join(__file__,'../../../../../share/'))
env = {
    'ICU_DATA': path.join(mapnik_data_dir, 'icu'),
    'GDAL_DATA': path.join(mapnik_data_dir, 'gdal'),
    'PROJ_LIB': path.join(mapnik_data_dir, 'proj')
}
" > bindings/python/mapnik/mapnik_settings.py


