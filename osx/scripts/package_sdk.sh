# where we are headed
TARGET_BASENAME="${MAPNIK_TAR_DIR}-osx-sdk"
LOCAL_TARGET="${MAPNIK_DIST}/${TARGET_BASENAME}"

# clear out mapnik
cd ${MAPNIK_SOURCE}
make uninstall

# package more boost headers
# (only needed to compile mapnik itself)
cd ${PACKAGES}/boost*/
mkdir boost-staging
./dist/bin/bcp \
boost/system/error_code.hpp \
boost/cerrno.hpp \
boost/filesystem/operations.hpp \
boost/program_options.hpp \
boost/property_tree/ptree.hpp \
boost/property_tree/xml_parser.hpp \
boost/format.hpp \
boost/spirit/include/phoenix_object.hpp \
boost/spirit/include/phoenix_stl.hpp \
boost/interprocess/mapped_region.hpp \
boost/interprocess/file_mapping.hpp \
boost/interprocess/streams/bufferstream.hpp \
boost/fusion/include/std_pair.hpp \
boost-staging/ 1>/dev/null
cp -r boost-staging/boost ${LOCAL_TARGET}/include/

cp ${BUILD}/include/png* ${LOCAL_TARGET}/include/

# jpeg
cp ${BUILD}/include/j*.h ${LOCAL_TARGET}/include/

# tiff
cp ${BUILD}/include/tiff* ${LOCAL_TARGET}/include/

# TODO - give up and copy all headers for now
# postgres,gdal,sqlite,tiff,jpeg
cp -r ${BUILD}/include/* ${LOCAL_TARGET}/include/

# config scripts
cp ${BUILD}/bin/freetype-config ${LOCAL_TARGET}/bin/
#cp ${BUILD}/bin/xml2-config ${LOCAL_TARGET}/bin/
cp ${BUILD}/bin/pg_config ${LOCAL_TARGET}/bin/
cp ${BUILD}/bin/gdal-config ${LOCAL_TARGET}/bin/


# libs
cp -R ${BUILD}/lib/lib*.a ${LOCAL_TARGET}/lib/
cp -R ${BUILD}/lib/libboost_regex-mapnik.dylib ${LOCAL_TARGET}/lib/libboost_regex.dylib
install_name_tool -id @loader_path/libboost_regex.dylib ${LOCAL_TARGET}/lib/libboost_regex.dylib
cp -R ${BUILD}/lib/libicu*.dylib ${LOCAL_TARGET}/lib/


# move to dist and package things up
cd ${MAPNIK_DIST}
rm -rf ./mapnik-osx-sdk.tar.bz2
mkdir -p $LOCAL_TARGET
rm -rf $LOCAL_TARGET/*
cp -R ${MAPNIK_INSTALL}/* ${LOCAL_TARGET}/

# WARNING, target must be relative here
tar cjf ./mapnik-osx-sdk.tar.bz2 ./${TARGET_BASENAME}



