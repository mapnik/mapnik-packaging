set -e

export PROJ_LIB=${MAPNIK_INSTALL}/share/proj
export GDAL_DATA=${MAPNIK_INSTALL}/share/gdal
#export DYLD_LIBRARY_PATH=${MAPNIK_INSTALL}/lib

cd ${MAPNIK_SOURCE}

for i in {"2.6","2.7"}
do
    export PYTHONPATH=${MAPNIK_INSTALL}/lib/python${i}/site-packages/
    make test
done
