set -e 
cd ${MAPNIK_SOURCE}

echo '...Updating and building mapnik minimal'

echo "PREFIX = '${MAPNIK_INSTALL}'" > config.py
echo "CXX = '${CXX}'" >> config.py
echo "CC = '${CC}'" >> config.py
echo "CUSTOM_CXXFLAGS = '${CXXFLAGS}'" >> config.py
echo "CUSTOM_LDFLAGS = '${LDFLAGS}'" >> config.py
echo "OPTIMIZATION = '${OPTIMIZATION}'" >> config.py
echo "RUNTIME_LINK = 'static'" >> config.py
echo "PATH = '../build/bin/'" >> config.py
echo "BOOST_INCLUDES = '../build/include'" >> config.py
echo "BOOST_LIBS = '../build/lib'" >> config.py
echo "FREETYPE_CONFIG = '../build/bin/freetype-config'" >> config.py
echo "ICU_INCLUDES = '../build/include'" >> config.py
echo "ICU_LIBS = '../build/lib'" >> config.py
echo "PNG_INCLUDES = '../build/include'" >> config.py
echo "PNG_LIBS = '../build/lib'" >> config.py

./configure \
  FULL_LIB_PATH=False \
  BINDINGS='' \
  INPUT_PLUGINS=shape \
  SAMPLE_INPUT_PLUGINS=False \
  CAIRO=False \
  JPEG=False \
  TIFF=False \
  PROJ=False \
  SVG2PNG=False \
  SHAPEINDEX=False \
  CPP_TESTS=True \
  DEMO=False \
  SVG_RENDERER=False \
  PGSQL2SQLITE=False \
  SYSTEM_FONTS=/System/Library/Fonts
make
make install