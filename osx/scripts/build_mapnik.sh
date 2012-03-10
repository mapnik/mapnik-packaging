set -e 
cd ${MAPNIK_SOURCE}

echo '...Updating and building mapnik'

#git checkout osx-framework
git pull origin master
echo "PREFIX = '${MAPNIK_INSTALL}'" > config.py
echo "PYTHON_PREFIX = '${MAPNIK_INSTALL}'" >> config.py
cat ${ROOTDIR}/patches/config.py >> config.py

./configure BINDINGS=''
make
make install

# python versions
for i in {"2.6","2.7"}
do
    echo "...Updating and building mapnik python bindings for python ${i}"
    # TODO - cpu waste
    #rm -f bindings/python/*os
    #rm -f bindings/python/mapnik/_mapnik.so
    ./configure BINDINGS=python PYTHON=/usr/bin/python${i} BOOST_PYTHON_LIB=boost_python-${i}
    make install
done