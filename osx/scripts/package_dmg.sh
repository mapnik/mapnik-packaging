#!/bin/bash
set -e -u -x

echo '...packaging DMG'
#install_name_tool -id ${MAPNIK_BIN_SOURCE}/lib/libmapnik.dylib ${MAPNIK_BIN_SOURCE}/lib/libmapnik.dylib
rm -f ${ROOTDIR}/installer/*dmg
rm -rf ${ROOTDIR}/installer/build/*pkg
freeze ${ROOTDIR}/installer/Mapnik.packproj
FOUND_VERSION=`${MAPNIK_BIN_SOURCE}/bin/mapnik-config --version`
echo "Mapnik v${FOUND_VERSION}" > ${ROOTDIR}/installer/build/build.log
echo "Build on `date`" >> ${ROOTDIR}/installer/build/build.log
echo "clang --version:" >> ${ROOTDIR}/installer/build/build.log
${CXX} -v >> ${ROOTDIR}/installer/build/build.log 2>&1
cp ${ROOTDIR}/installer/media/welcome.txt ${ROOTDIR}/installer/build/README.txt
MAPNIK_DMG_VOL_NAME="Mapnik ${FOUND_VERSION}"
MAPNIK_DMG_NAME="${MAPNIK_PACKAGE_PREFIX}-osx-v${FOUND_VERSION}.dmg"
hdiutil create \
  "${ROOTDIR}/installer/${MAPNIK_DMG_NAME}" \
  -volname "${MAPNIK_DMG_VOL_NAME}" \
  -srcfolder ${ROOTDIR}/installer/build
# upload
UPLOAD="s3://mapnik/dist/v${FOUND_VERSION}/${MAPNIK_DMG_NAME}"
/usr/local/bin/s3cmd --acl-public put "${ROOTDIR}/installer/${MAPNIK_DMG_NAME}" ${UPLOAD}
