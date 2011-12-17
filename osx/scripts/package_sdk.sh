# clear out mapnik
cd ${MAPNIK_SOURCE}
make uninstall

# move to dist and package things up
cd ${MAPNIK_DIST}
rm -rf ./mapnik-sdk.tar.bz2
LOCAL_TARGET="./${MAPNIK_TAR_DIR}-sdk"
mkdir -p $LOCAL_TARGET
rm -rf $LOCAL_TARGET/*
cp -R ${MAPNIK_INSTALL}/* $LOCAL_TARGET/
tar cjf ${MAPNIK_DIST}/mapnik-sdk.tar.bz2 ${MAPNIK_TAR_DIR}/