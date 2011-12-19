echo '...packaging DMG'
install_name_tool -id ${MAPNIK_INSTALL}/lib/libmapnik.dylib ${MAPNIK_INSTALL}/lib/libmapnik.dylib
rm ${ROOTDIR}/installer/*dmg
rm ${ROOTDIR}/installer/pkg/*pkg
packagemaker --doc ${ROOTDIR}/installer/mapnik.pmdoc --out ${ROOTDIR}/installer/pkg/Mapnik.pkg
packagemaker --doc ${ROOTDIR}/installer/uninstall.pmdoc --out ${ROOTDIR}/installer/pkg/Uninstall-Mapnik.pkg
hdiutil create "${ROOTDIR}/installer/mapnik_2.0.0.dmg" -volname "Mapnik 2.0.0" -fs HFS+ -srcfolder ${ROOTDIR}/installer/pkg
