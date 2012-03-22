set -e

# TODO - refactor for re-usability

echo "...fixing install names of mapnik and dependencies"

# -R is needed to preserve symlinks
<<COMMENT
#cp -R ${BUILD}/lib/libboost_regex-mapnik*.dylib ${MAPNIK_INSTALL}/lib/
cp -R ${BUILD}/lib/libicuuc*.dylib ${MAPNIK_INSTALL}/lib/
cp -R ${BUILD}/lib/libicudata*.dylib ${MAPNIK_INSTALL}/lib/
cp -R ${BUILD}/lib/libicui18n*.dylib ${MAPNIK_INSTALL}/lib/
COMMENT
mkdir -p ${MAPNIK_INSTALL}/share/
mkdir -p ${MAPNIK_INSTALL}/share/icu
# TODO - replace with actual icu version
cp ${BUILD}/share/icu/*/icudt*.dat ${MAPNIK_INSTALL}/share/icu/
cp -R ${BUILD}/share/proj ${MAPNIK_INSTALL}/share/proj
cp -R ${BUILD}/share/gdal ${MAPNIK_INSTALL}/share/gdal


# python
for i in {"2.6","2.7"}
do
    cp -R ${BUILD}/lib/libboost_python-${i}.dylib ${MAPNIK_INSTALL}/lib/python${i}/site-packages/mapnik/
done

# TODO - make linking dynamic
for i in $(ls ${MAPNIK_INSTALL}/lib/mapnik/input/*input)
do
  install_name_tool -change libmapnik.dylib @loader_path/../../libmapnik.dylib ${i}
  #install_name_tool -change libicuuc.${ICU_MAJOR_VER}.dylib @loader_path/../../libicuuc.dylib ${i}
done

# fix pgsql2sqlite
install_name_tool -change libmapnik.dylib @loader_path/../lib/libmapnik.dylib ${MAPNIK_INSTALL}/bin/pgsql2sqlite

# fix libmapnik
#install_name_tool -change libicuuc.${ICU_MAJOR_VER}.dylib @loader_path/libicuuc.${ICU_MAJOR_VER}.dylib ${MAPNIK_INSTALL}/lib/libmapnik.dylib
# library
#install_name_tool -change ../lib/libicudata.${ICU_MAJOR_VER}.1.1.dylib @loader_path/libicudata.${ICU_MAJOR_VER}.1.1.dylib ${MAPNIK_INSTALL}/lib/libmapnik.dylib
# archive
#install_name_tool -change libicudata.${ICU_MAJOR_VER}.dylib @loader_path/libicudata.${ICU_MAJOR_VER}.dylib ${MAPNIK_INSTALL}/lib/libmapnik.dylib
#install_name_tool -change libicui18n.${ICU_MAJOR_VER}.dylib @loader_path/libicui18n.${ICU_MAJOR_VER}.dylib ${MAPNIK_INSTALL}/lib/libmapnik.dylib
#install_name_tool -change libboost_regex-mapnik.dylib @loader_path/libboost_regex-mapnik.dylib ${MAPNIK_INSTALL}/lib/libmapnik.dylib

# fix boost_regex
#install_name_tool -change libicuuc.${ICU_MAJOR_VER}.dylib @loader_path/libicuuc.${ICU_MAJOR_VER}.dylib ${MAPNIK_INSTALL}/lib/libboost_regex-mapnik.dylib
# library
#install_name_tool -change ../lib/libicudata.${ICU_MAJOR_VER}.1.1.dylib @loader_path/libicudata.${ICU_MAJOR_VER}.1.1.dylib ${MAPNIK_INSTALL}/lib/libboost_regex-mapnik.dylib
# archive
#install_name_tool -change libicudata.${ICU_MAJOR_VER}.dylib @loader_path/libicudata.${ICU_MAJOR_VER}.dylib ${MAPNIK_INSTALL}/lib/libboost_regex-mapnik.dylib
#install_name_tool -change libicui18n.${ICU_MAJOR_VER}.dylib @loader_path/libicui18n.${ICU_MAJOR_VER}.dylib ${MAPNIK_INSTALL}/lib/libboost_regex-mapnik.dylib

# fix python

for i in {"2.6","2.7"}
do
    install_name_tool -change libmapnik.dylib @loader_path/../../../libmapnik.dylib ${MAPNIK_INSTALL}/lib/python${i}/site-packages/mapnik/_mapnik.so
done

<<COMMENT
# fix icu linking
install_name_tool -change ../lib/libicudata.${ICU_MAJOR_VER}.1.1.dylib @loader_path/libicudata.${ICU_MAJOR_VER}.dylib ${MAPNIK_INSTALL}/lib/libicuuc.dylib
install_name_tool -change ../lib/libicudata.${ICU_MAJOR_VER}.1.1.dylib @loader_path/libicudata.${ICU_MAJOR_VER}.dylib ${MAPNIK_INSTALL}/lib/libicui18n.dylib
install_name_tool -id @loader_path/libicudata.${ICU_MAJOR_VER}.dylib ${MAPNIK_INSTALL}/lib/libicudata.dylib

install_name_tool -change libicudata.${ICU_MAJOR_VER}.dylib @loader_path/libicudata.${ICU_MAJOR_VER}.dylib ${MAPNIK_INSTALL}/lib/libicuuc.dylib
install_name_tool -change libicudata.${ICU_MAJOR_VER}.dylib @loader_path/libicudata.${ICU_MAJOR_VER}.dylib ${MAPNIK_INSTALL}/lib/libicui18n.dylib
install_name_tool -change libicuuc.${ICU_MAJOR_VER}.dylib @loader_path/libicuuc.${ICU_MAJOR_VER}.dylib ${MAPNIK_INSTALL}/lib/libicui18n.dylib
COMMENT

# cleanups
find ${MAPNIK_INSTALL} -name ".DS_Store" -exec rm -f {} \;
