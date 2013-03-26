set -e 
cd ${MAPNIK_SOURCE}

echo '...Updating and building mapnik'

#git checkout osx-framework
#git pull origin master
echo "PREFIX = '${MAPNIK_INSTALL}'" > config.py
echo "PYTHON_PREFIX = '${MAPNIK_INSTALL}'" >> config.py
echo "CXX = '${CXX}'" >> config.py
echo "CC = '${CC}'" >> config.py
echo "CUSTOM_CXXFLAGS = '${CXXFLAGS}'" >> config.py
echo "CUSTOM_CFLAGS = '${CFLAGS}'" >> config.py
echo "CUSTOM_LDFLAGS = '${LDFLAGS}'" >> config.py
echo "OPTIMIZATION = '${OPTIMIZATION}'" >> config.py
cat ${ROOTDIR}/patches/config.py >> config.py

# write mapnik_settings.py
echo "
from os import path
mapnik_data_dir = path.normpath(path.join(__file__,'../../../../../share/'))
env = {
    'ICU_DATA': path.join(mapnik_data_dir, 'icu'),
    'GDAL_DATA': path.join(mapnik_data_dir, 'gdal'),
    'PROJ_LIB': path.join(mapnik_data_dir, 'proj')
}
" > bindings/python/mapnik/mapnik_settings.py

./configure \
  PATH_REMOVE="/usr/include" \
  BINDINGS='' \
  INPUT_PLUGINS=all \
  CAIRO=True \
  JOBS=6 \
  DEMO=True \
  PGSQL2SQLITE=True \
  FRAMEWORK_PYTHON=False \ # so linking works to custom framework despite use of -isysroot
  BOOST_PYTHON_LIB=boost_python-2.7
make
make install

# python versions
export i="3.3"
echo "...Updating and building mapnik python bindings for python ${i}"
rm -f plugins/input/python.input
rm -f plugins/input/python/*os
rm -f bindings/python/*os
rm -f bindings/python/mapnik/_mapnik.so
./configure BINDINGS=python PYTHON=/usr/local/bin/python${i} BOOST_PYTHON_LIB=boost_python-${i}
make
mv plugins/input/python.input ${MAPNIK_INSTALL}/lib/mapnik/input/python${i}.input
make install

for i in {"2.6","2.7"}
do
  echo "...Updating and building mapnik python bindings for python ${i}"
  rm -f plugins/input/python.input
  rm -f plugins/input/python/*os
  rm -f bindings/python/*os
  rm -f bindings/python/mapnik/_mapnik.so
  ./configure BINDINGS=python PYTHON=/usr/bin/python${i} BOOST_PYTHON_LIB=boost_python-${i}
  make
  mv plugins/input/python.input ${MAPNIK_INSTALL}/lib/mapnik/input/python${i}.input
  make install
done
# clear for now
rm -f ${MAPNIK_INSTALL}/lib/mapnik/input/python*input
rm -f plugins/input/python*input

