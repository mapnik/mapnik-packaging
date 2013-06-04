set -e

echo '...packaging ios sdk tarball'

# where we are headed
cd ${MAPNIK_DIST}
PACKAGE_NAME="${MAPNIK_PACKAGE_PREFIX}-ios"
TARGET_BASENAME="${PACKAGE_NAME}-sdk"
LOCAL_TARGET="${MAPNIK_DIST}/${TARGET_BASENAME}"
mkdir -p "${LOCAL_TARGET}"
STAGING_DIR="boost-staging-minimal"

# clear up where we're going
rm -rf ${LOCAL_TARGET}/*

echo '...creating base directories'

mkdir ${LOCAL_TARGET}/lib
mkdir ${LOCAL_TARGET}/include
#mkdir ${LOCAL_TARGET}/share/mapnik
mkdir ${LOCAL_TARGET}/bin

echo '...copying over mapnik'
cp ${BUILD_ROOT}-i386-mapnik${MAPNIK_INSTALL}/bin/mapnik-config ${LOCAL_TARGET}/bin/
cp ${BUILD_ROOT}-i386/bin/protoc ${LOCAL_TARGET}/bin/
cp -R ${MAPNIK_BIN_SOURCE}/include/ ${LOCAL_TARGET}/include/
#mkdir -p ${LOCAL_TARGET}/share/mapnik/icu
#if [ $BOOST_ARCH = "x86" ]; then
#  cp -R ${BUILD_ROOT}-i386/share/icu/*/icudt*.dat ${LOCAL_TARGET}/share/mapnik/icu/
#fi
# shape plugin
#if [ -d ${MAPNIK_BIN_SOURCE}/lib/mapnik/input/ ];then
#  mkdir -p ${LOCAL_TARGET}/lib/mapnik/input
#  cp ${MAPNIK_BIN_SOURCE}/lib/mapnik/input/* ${LOCAL_TARGET}/lib/mapnik/input/
#fi

echo '...packaging boost headers'
cd ${PACKAGES}/boost*-x86_64/
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
boost/operators.hpp \
boost/iterator/filter_iterator.hpp \
boost/concept_check.hpp \
boost/thread.hpp \
boost/thread/mutex.hpp \
boost/functional/hash.hpp \
boost/property_tree/ptree_fwd.hpp \
boost/interprocess/mapped_region.hpp \
boost/math/constants/constants.hpp \
boost/algorithm/string/predicate.hpp \
boost/spirit/include/qi.hpp \
boost/spirit/include/phoenix_function.hpp \
boost/spirit/include/phoenix_core.hpp \
boost/spirit/include/phoenix_operator.hpp \
boost/spirit/include/phoenix_fusion.hpp \
boost/spirit/include/phoenix_object.hpp \
boost/spirit/include/phoenix_stl.hpp \
boost/regex.hpp \
boost/regex/icu.hpp \
boost/iostreams/device/file.hpp \
boost/iostreams/stream.hpp \
boost/iostreams/device/array.hpp \
${STAGING_DIR}/ 1>/dev/null
cp -r ${STAGING_DIR}/boost ${LOCAL_TARGET}/include/

echo "*copying other headers*"
# icu
cp -r ${BUILD}/include/unicode ${LOCAL_TARGET}/include/

# jpeg
cp -r ${BUILD}/include/j* ${LOCAL_TARGET}/include/

# png
cp -r ${BUILD}/include/p* ${LOCAL_TARGET}/include/

# zlib
cp -r ${BUILD}/include/z* ${LOCAL_TARGET}/include/

# protobuf
cp -r ${BUILD}/include/google ${LOCAL_TARGET}/include/

# libraries
cp ${BUILD_UNIVERSAL}/* ${LOCAL_TARGET}/lib/

cd ${MAPNIK_DIST}
rm -f ./${PACKAGE_NAME}*.tar.bz2
FOUND_VERSION=`mapnik-config --version`
DESCRIBE=`mapnik-config --git-describe`
echo ${DESCRIBE} > ${LOCAL_TARGET}/VERSION

echo "...creating tarball of mapnik build"
TEMP_SYMLINK="${MAPNIK_DIST}/${PACKAGE_NAME}"
ln -s ${LOCAL_TARGET} ${TEMP_SYMLINK}
tar cjfH ${MAPNIK_DIST}/${PACKAGE_NAME}-${DESCRIBE}.tar.bz2 ${PACKAGE_NAME}/
UPLOAD="s3://mapnik/dist/v${FOUND_VERSION}/${PACKAGE_NAME}-${DESCRIBE}.tar.bz2"
echo "*uploading ${UPLOAD}"
/usr/local/bin/s3cmd --acl-public put ${MAPNIK_DIST}/${PACKAGE_NAME}-${DESCRIBE}.tar.bz2 ${UPLOAD}
rm ${TEMP_SYMLINK}
# update https://gist.github.com/springmeyer/eab2ff20ac560fbb9dd9
