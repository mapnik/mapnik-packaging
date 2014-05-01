#!/usr/bin/env bash
set -e -u
set -o pipefail
mkdir -p ${PACKAGES}
cd ${PACKAGES}

echoerr 'building OSM-binary'
rm -rf OSM-binary
git clone --quiet https://github.com/scrosby/OSM-binary.git
cd OSM-binary
git checkout ed845badf9980c5
cd src
if [ "${AR:-false}" != false ]; then
  $MAKE CXX=$CXX AR=$AR CXXFLAGS="${CXXFLAGS}"
else
  $MAKE CXX=$CXX CXXFLAGS="${CXXFLAGS}"
fi 
$MAKE install PREFIX=${BUILD}
cd ${PACKAGES}
