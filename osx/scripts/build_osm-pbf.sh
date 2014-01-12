#!/bin/bash
set -e -u -x

mkdir -p ${PACKAGES}
cd ${PACKAGES}

echoerr 'building OSM-binary'
rm -rf OSM-binary
git clone --depth=0 https://github.com/scrosby/OSM-binary.git
cd OSM-binary/src
if [ "${AR:-false}" != false ]; then
  make CXX=$CXX AR=$AR CXXFLAGS="${CXXFLAGS}"
else
  make CXX=$CXX CXXFLAGS="${CXXFLAGS}"
fi 
make install PREFIX=${BUILD}
cd ${PACKAGES}
