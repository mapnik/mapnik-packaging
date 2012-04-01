set -e

echo '...packaging binary tarball'

cd ${MAPNIK_DIST}
rm -rf ./${MAPNIK_PACKAGE_PREFIX}*.tar.bz2
mkdir -p ${MAPNIK_PACKAGE_PREFIX}
rm -rf ./${MAPNIK_PACKAGE_PREFIX}/*
# TODO - make symlink and resolve during tar instead of copy?
cp -R ${MAPNIK_INSTALL}/* ${MAPNIK_DIST}/${MAPNIK_PACKAGE_PREFIX}/
install_name_tool -id @loader_path/${MAPNIK_PACKAGE_PREFIX}/lib/libmapnik.dylib ${MAPNIK_DIST}/${MAPNIK_PACKAGE_PREFIX}/lib/libmapnik.dylib
FOUND_VERSION=`mapnik-config --version`

tar cjf ${MAPNIK_DIST}/mapnik-${FOUND_VERSION}${MAPNIK_DEV_POSTFIX}.tar.bz2 ${MAPNIK_PACKAGE_PREFIX}/