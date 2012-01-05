cd ${MAPNIK_SOURCE}
export DYLD_LIBRARY_PATH=''
export PROJ_LIB=${MAPNIK_INSTALL}/share/proj
export GDAL_DATA=${MAPNIK_INSTALL}/share/gdal
export PYTHONPATH=${MAPNIK_INSTALL}/lib/python2.7/site-packages/
export PATH=${MAPNIK_INSTALL}/bin:$PATH
make test
