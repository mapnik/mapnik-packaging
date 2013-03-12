source settings.sh
./scripts/setup.sh
./scripts/download_deps.sh
./scripts/build_deps.sh
./scripts/build_deps_cairo.sh

# update mapnik
cd mapnik
git fetch
#git checkout v2.1.0
cd ../

rm -rf ${MAPNIK_INSTALL}
cd scripts/

# build mapnik
./build_mapnik.sh

# make portable
./post_build_fix.sh

# test mapnik
./test_mapnik.sh

# manually edit mapnik-config if this is not
# a full SDK build
# /Library/Frameworks/Mapnik.framework/unix/bin/mapnik-config

# package dmg
# packagemaker is borked in recent xcode upgrade
#./package_dmg.sh

# copy minimal headers of deps
./copy_headers.sh

# package mapnik tarball
./package_tarball.sh

# then uninstall mapnik and package sdk
./package_sdk.sh

# uploads
#./upload.sh
