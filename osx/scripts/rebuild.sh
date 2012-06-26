source settings.sh
./scripts/setup.sh
./scripts/download_deps.sh
./scripts/build_deps.sh
./scripts/build_deps_cairo.sh

rm -rf ${MAPNIK_INSTALL}
cd scripts/

# build mapnik
./build_mapnik.sh

# make portable
./post_build_fix.sh

# test mapnik
./test_mapnik.sh

# package dmg
./package_dmg.sh

# copy minimal headers of deps
./copy_headers.sh

# package mapnik tarball
./package_tarball.sh

# then uninstall mapnik and package sdk
./package_sdk.sh

# uploads
#./upload.sh
