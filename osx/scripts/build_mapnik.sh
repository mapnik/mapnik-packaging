set -e 

cd ${ROOT_DIR}

git clone https://github.com/mapnik/mapnik ${MAPNIK_SOURCE}
cd ${MAPNIK_SOURCE}
cp ${ROOT_DIR}/patches/config.py .
git apply ${ROOT_DIR}/patches/master.diff
./configure BINDINGS=''
make
make install

cd ${MAPNIK_SOURCE}
#make uninstall

# python versions
for i in {"2.6","2.7"}
do
    rm -f bindings/python/*os
    rm -f bindings/python/mapnik/_mapnik.so
    ./configure BINDINGS=python PYTHON=/usr/bin/python${i} BOOST_PYTHON_LIB=boost_python-${i}
    make install
done