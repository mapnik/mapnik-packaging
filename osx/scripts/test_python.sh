#!/usr/bin/env bash
set -e -u
set -o pipefail
export PROJ_LIB=${MAPNIK_BIN_SOURCE}/share/mapnik/proj
export GDAL_DATA=${MAPNIK_BIN_SOURCE}/share/mapnik/gdal
#export DYLD_LIBRARY_PATH=${MAPNIK_INSTALL}/lib

cd ${MAPNIK_SOURCE}

for i in {"2.6","2.7"}
do
    export PYTHONPATH=${MAPNIK_BIN_SOURCE}/lib/python${i}/site-packages/
    make test
done
