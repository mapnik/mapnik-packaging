source settings.sh
# setup.sh
# download_deps.sh
# build_deps.sh

rm -rf ${MAPNIK_INSTALL}
cd scripts/

# build mapnik
./build_mapnik.sh

# make portable
./post_build_fix.sh

# test mapnik
./test_mapnik.sh

# package mapnik tarball
./package_tarball.sh

# both dmg and sdk need headers of deps
# so copy them now...
./copy_headers.sh

# package dmg
./package_dmg.sh

# the uninstall mapnik and package sdk
./package_sdk.sh
