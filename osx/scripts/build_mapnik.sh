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
echo "CUSTOM_LDFLAGS = '${LDFLAGS}'" >> config.py
echo "OPTIMIZATION = '${OPTIMIZATION}'" >> config.py
cat ${ROOTDIR}/patches/config.py >> config.py

#rm plugins/input/*input
#rm src/*dylib
./configure \
  BINDINGS='' \
  INPUT_PLUGINS=all \
  CAIRO=True \
  JOBS=6 \
  DEMO=True \
  PGSQL2SQLITE=True
make # so cpp tests get built
make install

# python versions
for i in {"2.6","2.7"}
do
  echo "...Updating and building mapnik python bindings for python ${i}"
  ./configure BINDINGS=python PYTHON=/usr/bin/python${i} BOOST_PYTHON_LIB=boost_python-${i}
  make install
done

export i="3.3"
echo "...Updating and building mapnik python bindings for python ${i}"
rm -f bindings/python/*os
rm -f bindings/python/mapnik/_mapnik.so
./configure BINDINGS=python PYTHON=/usr/local/bin/python${i} BOOST_PYTHON_LIB=boost_python-${i}
make install
