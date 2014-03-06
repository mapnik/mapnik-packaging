#!/bin/bash
set -e -u

mkdir -p ${PACKAGES}
cd ${PACKAGES}

echoerr 'building OSM-binary'
rm -rf OSM-binary
git clone --quiet https://github.com/scrosby/OSM-binary.git
cd OSM-binary
git checkout ed845badf9980c5
cd src
if [ "${AR:-false}" != false ]; then
  make CXX=$CXX AR=$AR CXXFLAGS="${CXXFLAGS}"
else
  make CXX=$CXX CXXFLAGS="${CXXFLAGS}"
fi 
make install PREFIX=${BUILD}
cd ${PACKAGES}
