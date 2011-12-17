cd ${MAPNIK_SOURCE}
MAPNIK_HASH=`git reflog show HEAD | sed -n '1p' | awk '{ print $1 }'`

cd ${MAPNIK_DIST}
rm -rf ./mapnik-2.1~dev-*.tar.bz2
mkdir -p ${MAPNIK_TAR_DIR}
rm -rf ./${MAPNIK_TAR_DIR}/*
cp -R ${MAPNIK_INSTALL}/* ${MAPNIK_DIST}/${MAPNIK_TAR_DIR}/
install_name_tool -id @loader_path/${MAPNIK_TAR_DIR}/lib/libmapnik.dylib ${MAPNIK_DIST}/${MAPNIK_TAR_DIR}/lib/libmapnik.dylib

tar cjf ${MAPNIK_DIST}/mapnik-2.1~dev-${MAPNIK_HASH}.tar.bz2 ${MAPNIK_TAR_DIR}/