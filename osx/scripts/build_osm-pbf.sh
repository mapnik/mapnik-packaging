#!/bin/bash
set -e -u

mkdir -p ${PACKAGES}
cd ${PACKAGES}

echoerr 'building OSM-binary'
rm -rf OSM-binary
git clone --quiet --depth=1 https://github.com/scrosby/OSM-binary.git
cd OSM-binary
git checkout 81985fec4a5cc9a3c41a9e93a1772a0a0aea66af
cd src
if [ "${AR:-false}" != false ]; then
  make CXX=$CXX AR=$AR CXXFLAGS="${CXXFLAGS}"
else
  make CXX=$CXX CXXFLAGS="${CXXFLAGS}"
fi 
make install PREFIX=${BUILD}
cd ${PACKAGES}
