set -e
mkdir -p ${PACKAGES}
cd ${PACKAGES}

rm -rf v1.3.0.tar.gz
wget https://github.com/scrosby/OSM-binary/archive/v1.3.0.tar.gz
tar xf v1.3.0.tar.gz
cd OSM-binary-1.3.0/src
patch -N < $PATCHES/osm-pbf.diff
make CXX=$CXX AR=$AR CXXFLAGS="${CXXFLAGS}"
make install DESTDIR=${BUILD}
cd ${PACKAGES}
