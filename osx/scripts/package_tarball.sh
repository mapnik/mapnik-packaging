#!/bin/bash
set -e -u -x

echo '...packaging binary tarball'
mkdir -p ${MAPNIK_DIST}
cd ${MAPNIK_DIST}
rm -rf ./${MAPNIK_PACKAGE_PREFIX}*.tar.bz2
FOUND_VERSION=`mapnik-config --version`

# symlink approach
ln -s ${MAPNIK_BIN_SOURCE} ${MAPNIK_DIST}/${MAPNIK_PACKAGE_PREFIX}
tar cjfH ${MAPNIK_DIST}/mapnik-${FOUND_VERSION}.tar.bz2 ${MAPNIK_PACKAGE_PREFIX}/
# cleanup symlink
rm ${MAPNIK_DIST}/${MAPNIK_PACKAGE_PREFIX}

# copy approach
<<COMMENT
mkdir -p ${MAPNIK_PACKAGE_PREFIX}
rm -rf ./${MAPNIK_PACKAGE_PREFIX}/*
cp -R ${MAPNIK_BIN_SOURCE}/* ${MAPNIK_DIST}/${MAPNIK_PACKAGE_PREFIX}/
install_name_tool -id @loader_path/${MAPNIK_PACKAGE_PREFIX}/lib/libmapnik.dylib ${MAPNIK_DIST}/${MAPNIK_PACKAGE_PREFIX}/lib/libmapnik.dylib
tar cjf ${MAPNIK_DIST}/mapnik-${FOUND_VERSION}.tar.bz2 ${MAPNIK_PACKAGE_PREFIX}/
COMMENT