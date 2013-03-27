set -e
echo '...packaging sdk tarball'

# where we are headed
TARGET_BASENAME="${MAPNIK_PACKAGE_PREFIX}-osx-sdk"
LOCAL_TARGET="${MAPNIK_DIST}/${TARGET_BASENAME}"
mkdir -p "${LOCAL_TARGET}"


# clear out mapnik
cd ${MAPNIK_SOURCE}
make uninstall
# also remove python versions
rm -rf ${MAPNIK_BIN_SOURCE}/lib/python*
# clear up where wer're going
rm -rf ${LOCAL_TARGET}/*
# now establish a base of data
cp -R ${MAPNIK_BIN_SOURCE}/* ${LOCAL_TARGET}/

# package more boost headers
# (only needed to compile mapnik itself)
cd ${PACKAGES}/boost*/
mkdir -p boost-staging
echo '...copying boost headers'
./dist/bin/bcp \
boost/thread/mutex.hpp \
boost/regex.hpp \
boost/unordered_map.hpp \
boost/make_shared.hpp \
boost/variant.hpp \
boost/algorithm/string.hpp \
boost/spirit/include/qi.hpp \
boost/spirit/include/qi_action.hpp \
boost/ptr_container/ptr_vector.hpp \
boost/property_map/property_map.hpp \
boost/math/constants/constants.hpp \
boost/spirit/include/phoenix_operator.hpp \
boost/spirit/include/phoenix_fusion.hpp \
boost/fusion/include/adapt_struct.hpp \
boost/fusion/include/adapt_adt.hpp \
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
boost/python/detail/api_placeholder.hpp \
boost/range/algorithm.hpp \
boost/spirit/include/karma.hpp \
boost/spirit/include/phoenix.hpp \
boost/fusion/include/boost_tuple.hpp \
boost/spirit/include/support_multi_pass.hpp \
boost/math/special_functions/round.hpp \
boost-staging/ 1>/dev/null
cp -r boost-staging/boost ${LOCAL_TARGET}/include/

# png
echo '...copying png headers'
cp ${BUILD}/include/png* ${LOCAL_TARGET}/include/

# jpeg
echo '...copying jpeg headers'
cp ${BUILD}/include/j*.h ${LOCAL_TARGET}/include/

# tiff
echo '...copying tiff headers'
cp ${BUILD}/include/tiff* ${LOCAL_TARGET}/include/

# todo ogr_frmts

# TODO - give up and copy all headers for now
# postgres,gdal,sqlite,tiff,jpeg
#echo '...copying all headers'
#cp -r ${BUILD}/include/* ${LOCAL_TARGET}/include/

# config scripts
echo '...copying a few config programs'
cp ${BUILD}/bin/freetype-config ${LOCAL_TARGET}/bin/
#cp ${BUILD}/bin/xml2-config ${LOCAL_TARGET}/bin/
cp ${BUILD}/bin/pg_config ${LOCAL_TARGET}/bin/
cp ${BUILD}/bin/gdal-config ${LOCAL_TARGET}/bin/


# libs
echo '...copying static libs'
cp -R ${BUILD}/lib/lib*.a ${LOCAL_TARGET}/lib/

echo "...moving packaging into place: ${MAPNIK_DIST}"
# move to dist and package things up
cd ${MAPNIK_DIST}
rm -rf ./mapnik-osx-sdk.tar.bz2

# WARNING, target must be relative here
tar cjf ./${TARGET_BASENAME}.tar.bz2 ./${TARGET_BASENAME}



