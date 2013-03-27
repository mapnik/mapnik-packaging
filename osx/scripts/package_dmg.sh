set -e
echo '...packaging DMG'
install_name_tool -id ${MAPNIK_BIN_SOURCE}/lib/libmapnik.dylib ${MAPNIK_BIN_SOURCE}/lib/libmapnik.dylib
rm -f ${ROOTDIR}/installer/*dmg
rm -f ${ROOTDIR}/installer/pkg/*pkg
packagemaker --doc ${ROOTDIR}/installer/mapnik.pmdoc --out ${ROOTDIR}/installer/pkg/Mapnik.pkg
packagemaker --doc ${ROOTDIR}/installer/uninstall.pmdoc --out ${ROOTDIR}/installer/pkg/Uninstall-Mapnik.pkg
FOUND_ACTIVE_VERSION=`${MAPNIK_BIN_SOURCE}/bin/mapnik-config --version`
MAPNIK_DMG_VOL_NAME="Mapnik ${FOUND_ACTIVE_VERSION}"
MAPNIK_DMG_NAME="${MAPNIK_PACKAGE_PREFIX}-v${FOUND_ACTIVE_VERSION}.dmg"
hdiutil create \
  "${ROOTDIR}/installer/${MAPNIK_DMG_NAME}" \
  -volname "${MAPNIK_DMG_VOL_NAME}" \
  -fs HFS+ \
  -srcfolder ${ROOTDIR}/installer/pkg
