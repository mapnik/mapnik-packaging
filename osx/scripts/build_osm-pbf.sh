#!/bin/bash
set -e -u

mkdir -p ${PACKAGES}
cd ${PACKAGES}

rm -rf v1.3.0
curl -s -S -f -O https://codeload.github.com/scrosby/OSM-binary/tar.gz/v1.3.0
tar xf v1.3.0
cd OSM-binary-1.3.0/src
patch -N < $PATCHES/osm-pbf.diff
if [ "${AR:-false}" != false ]; then
  make CXX=$CXX AR=$AR CXXFLAGS="${CXXFLAGS}"
else
  make CXX=$CXX CXXFLAGS="${CXXFLAGS}"
fi 
make install DESTDIR=${BUILD}
cd ${PACKAGES}
