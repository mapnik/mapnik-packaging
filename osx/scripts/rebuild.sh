source settings.sh
rm -rf ${MAPNIK_INSTALL}
scripts/build_mapnik.sh
scripts/post_build_fix.sh
scripts/copy_headers.sh
scripts/copy_licenses.sh
install_name_tool -id ${MAPNIK_INSTALL}/lib/libmapnik.dylib ${MAPNIK_INSTALL}/lib/libmapnik.dylib
rm installer/*dmg
rm installer/pkg/*pkg
packagemaker --doc installer/mapnik.pmdoc --out installer/pkg/Mapnik.pkg
packagemaker --doc installer/uninstall.pmdoc --out installer/pkg/Uninstall-Mapnik.pkg
hdiutil create "installer/mapnik_2.0.0.dmg" -volname "Mapnik 2.0.0" -fs HFS+ -srcfolder installer/pkg
