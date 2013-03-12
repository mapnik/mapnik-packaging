set -e

echo '...packaging minmal binary sdk tarball'

# where we are headed
cd ${MAPNIK_DIST}
CODENAME="minimal"
PACKAGE_NAME="${MAPNIK_PACKAGE_PREFIX}-${CODENAME}"
TARGET_BASENAME="${PACKAGE_NAME}-osx-sdk"
LOCAL_TARGET="${MAPNIK_DIST}/${TARGET_BASENAME}"
mkdir -p "${LOCAL_TARGET}"
STAGING_DIR="boost-staging-minimal"

# clear up where wer're going
rm -rf ${LOCAL_TARGET}/*

echo '...creating base directories'

mkdir ${LOCAL_TARGET}/lib
mkdir ${LOCAL_TARGET}/include
mkdir ${LOCAL_TARGET}/share
mkdir ${LOCAL_TARGET}/bin

echo '...copying over mapnik'
cp -R ${MAPNIK_INSTALL}/bin/mapnik-config ${LOCAL_TARGET}/bin/
cp -R ${MAPNIK_INSTALL}/lib/libmapnik.dylib ${LOCAL_TARGET}/lib/
cp -R ${MAPNIK_INSTALL}/include/ ${LOCAL_TARGET}/include/
mkdir ${LOCAL_TARGET}/share/icu
cp -R ${BUILD}/share/icu/*/icudt*.dat ${LOCAL_TARGET}/share/icu/

# feed the boost beast - 42 instead of 113 MB
echo '...packaging boost headers'
cd ${PACKAGES}/boost*/
mkdir -p ${STAGING_DIR}
./dist/bin/bcp \
boost/unordered_map.hpp \
boost/foreach.hpp \
boost/optional.hpp \
boost/ptr_container/ptr_vector.hpp \
boost/make_shared.hpp \
boost/shared_ptr.hpp \
boost/scoped_ptr.hpp \
boost/version.hpp \
boost/ptr_container/ptr_sequence_adapter.hpp \
boost/cstdint.hpp \
boost/variant.hpp \
${STAGING_DIR}/ 1>/dev/null
cp -r ${STAGING_DIR}/boost ${LOCAL_TARGET}/include/


boost/thread/mutex.hpp \
boost/regex.hpp \
boost/unordered_map.hpp \
boost/make_shared.hpp \
boost/variant.hpp \
boost/algorithm/string.hpp \
boost/spirit/include/qi.hpp \
boost/spirit/include/qi_action.hpp \
boost/property_map/property_map.hpp \
boost/math/constants/constants.hpp \
boost/spirit/include/phoenix_operator.hpp \
boost/spirit/include/phoenix_fusion.hpp \
boost/fusion/include/adapt_struct.hpp \
boost/fusion/include/adapt_adt.hpp \
boost/property_tree/ptree.hpp \
boost/any.hpp \
boost/optional.hpp \
boost/interprocess/mapped_region.hpp \
boost/multi_index/ordered_index.hpp \
${STAGING_DIR}/ 1>/dev/null
cp -r ${STAGING_DIR}/boost ${LOCAL_TARGET}/include/

# png
echo '...copying png headers'
cp ${BUILD}/include/png* ${LOCAL_TARGET}/include/

# jpeg
echo '...copying jpeg headers'
cp ${BUILD}/include/j*.h ${LOCAL_TARGET}/include/

cp -r ${BUILD}/include/unicode ${LOCAL_TARGET}/include/
cp -r ${BUILD}/include/freetype2 ${LOCAL_TARGET}/include/
cp -r ${BUILD}/include/ft2build.h ${LOCAL_TARGET}/include/ft2build.h
cp -r ${BUILD}/include/libxml2 ${LOCAL_TARGET}/include/

# libs
echo '...copying static libs'
#cp -R ${BUILD}/lib/libltdl*.a ${LOCAL_TARGET}/lib/
#cp -R ${BUILD}/lib/libpng*.a ${LOCAL_TARGET}/lib/
#cp -R ${BUILD}/lib/libz*.a ${LOCAL_TARGET}/lib/
#cp -R ${BUILD}/lib/libicuuc*.a ${LOCAL_TARGET}/lib/
#cp -R ${BUILD}/lib/libicui18n*.a ${LOCAL_TARGET}/lib/
#cp -R ${BUILD}/lib/libicudata*.a ${LOCAL_TARGET}/lib/
#cp -R ${BUILD}/lib/libfreetype*.a ${LOCAL_TARGET}/lib/
#cp -R ${BUILD}/lib/libxml2*.a ${LOCAL_TARGET}/lib/
#cp -R ${BUILD}/lib/libboost_filesystem*.a ${LOCAL_TARGET}/lib/
#cp -R ${BUILD}/lib/libboost_regex*.a ${LOCAL_TARGET}/lib/
#cp -R ${BUILD}/lib/libboost_thread*.a ${LOCAL_TARGET}/lib/
#cp -R ${BUILD}/lib/libboost_system*.a ${LOCAL_TARGET}/lib/

cd ${MAPNIK_DIST}
rm -f ./${PACKAGE_NAME}*.tar.bz2
FOUND_VERSION=`mapnik-config --version`

# symlink approach
echo "...creating tarball of mapnik-${FOUND_VERSION}${MAPNIK_DEV_POSTFIX}-${CODENAME}.tar.bz2"
ln -s ${MAPNIK_INSTALL} ${MAPNIK_DIST}/${PACKAGE_NAME}
tar cjfH ${MAPNIK_DIST}/mapnik-${FOUND_VERSION}${MAPNIK_DEV_POSTFIX}-${CODENAME}.tar.bz2 ${PACKAGE_NAME}/
# cleanup symlink
rm ${MAPNIK_DIST}/${PACKAGE_NAME}
