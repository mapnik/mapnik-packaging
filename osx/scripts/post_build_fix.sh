#!/bin/bash
set -e -u

echo "...fixing install names of mapnik and dependencies"

mkdir -p ${MAPNIK_BIN_SOURCE}/share/mapnik/
mkdir -p ${MAPNIK_BIN_SOURCE}/share/mapnik/icu
# TODO - replace with actual icu version
cp ${BUILD}/share/icu/*/icudt*.dat ${MAPNIK_BIN_SOURCE}/share/mapnik/icu/
if [ -d ${BUILD}/share/proj ];then
  cp -r ${BUILD}/share/proj ${MAPNIK_BIN_SOURCE}/share/mapnik/
fi
if [ -d ${BUILD}/share/gdal ];then
cp -r ${BUILD}/share/gdal ${MAPNIK_BIN_SOURCE}/share/mapnik/
fi

# py2cairo
for i in {"2.6","2.7","3.3"}
do
    if [ -d "${BUILD}/lib/python${i}/site-packages/cairo" ];then
        mkdir -p ${MAPNIK_BIN_SOURCE}/lib/python${i}/site-packages/
        cp -R ${BUILD}/lib/python${i}/site-packages/cairo ${MAPNIK_BIN_SOURCE}/lib/python${i}/site-packages/
    fi
done

# fixup plugins
for i in $(ls ${MAPNIK_BIN_SOURCE}/lib/mapnik/input/*input)
do
  install_name_tool -change libmapnik.dylib @loader_path/../../libmapnik.dylib ${i}
done

# fixup c++ programs
if [ -d "${MAPNIK_BIN_SOURCE}/bin/pgsql2sqlite" ]; then
    install_name_tool -change libmapnik.dylib @loader_path/../lib/libmapnik.dylib ${MAPNIK_BIN_SOURCE}/bin/pgsql2sqlite
fi
#install_name_tool -change libmapnik.dylib @loader_path/../lib/libmapnik.dylib ${MAPNIK_BIN_SOURCE}/bin/svg2png
for i in $(ls ${MAPNIK_SOURCE}/tests/cpp_tests/*-bin);
do install_name_tool -change libmapnik.dylib ${MAPNIK_BIN_SOURCE}/lib/libmapnik.dylib $i;
done

# fixup python

for i in {"2.6","2.7","3.3"}
do
    if [ -d "${MAPNIK_BIN_SOURCE}/lib/python${i}/site-packages/mapnik" ];then
        install_name_tool -change libmapnik.dylib @loader_path/../../../libmapnik.dylib ${MAPNIK_BIN_SOURCE}/lib/python${i}/site-packages/mapnik/_mapnik.so
    fi
done

# cleanups
find ${MAPNIK_BIN_SOURCE} -name ".DS_Store" -exec rm -f {} \;
