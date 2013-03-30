set -e

echo '...packaging minmal binary sdk tarball'

# where we are headed
cd ${MAPNIK_DIST}
PACKAGE_NAME="${MAPNIK_PACKAGE_PREFIX}"
TARGET_BASENAME="${PACKAGE_NAME}-osx-sdk"
LOCAL_TARGET="${MAPNIK_DIST}/${TARGET_BASENAME}"
mkdir -p "${LOCAL_TARGET}"
STAGING_DIR="boost-staging-minimal"

# clear up where we're going
rm -rf ${LOCAL_TARGET}/*

echo '...creating base directories'

mkdir ${LOCAL_TARGET}/lib
mkdir ${LOCAL_TARGET}/include
mkdir ${LOCAL_TARGET}/share
mkdir ${LOCAL_TARGET}/bin

echo '...copying over mapnik'
cp -R ${MAPNIK_BIN_SOURCE}/bin/mapnik-config ${LOCAL_TARGET}/bin/
cp -R ${MAPNIK_BIN_SOURCE}/lib/libmapnik.* ${LOCAL_TARGET}/lib/
cp -R ${MAPNIK_BIN_SOURCE}/include/ ${LOCAL_TARGET}/include/
mkdir -p ${LOCAL_TARGET}/share/icu
cp -R ${BUILD}/share/icu/*/icudt*.dat ${LOCAL_TARGET}/share/icu/
# shape plugin
if [ -d ${MAPNIK_BIN_SOURCE}/lib/mapnik/input/ ];then
  mkdir -p ${LOCAL_TARGET}/lib/mapnik/input
  cp ${MAPNIK_BIN_SOURCE}/lib/mapnik/input/* ${LOCAL_TARGET}/lib/mapnik/input/
fi
# feed the boost beast - 16 MB instead of 113 MB
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
boost/operators.hpp \
boost/iterator/filter_iterator.hpp \
boost/concept_check.hpp \
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
${STAGING_DIR}/ 1>/dev/null
cp -r ${STAGING_DIR}/boost ${LOCAL_TARGET}/include/

# icu
cp -r ${BUILD}/include/unicode ${LOCAL_TARGET}/include/

# ltdl
cp -r ${BUILD}/include/libltdl ${LOCAL_TARGET}/include/
cp -r ${BUILD}/include/ltdl.h ${LOCAL_TARGET}/include/

cd ${MAPNIK_DIST}
rm -f ./${PACKAGE_NAME}*.tar.bz2
FOUND_VERSION=`mapnik-config --version`
DESCRIBE=`mapnik-config --git-describe`
echo ${DESCRIBE} > ${LOCAL_TARGET}/VERSION

echo "...creating tarball of mapnik build"
TEMP_SYMLINK="${MAPNIK_DIST}/${PACKAGE_NAME}"
ln -s ${LOCAL_TARGET} ${TEMP_SYMLINK}
tar cjfH ${MAPNIK_DIST}/mapnik-osx-x86_64-${DESCRIBE}.tar.bz2 ${PACKAGE_NAME}/
#/usr/local/bin/s3cmd --acl-public put mapnik*tar.bz2 s3://mapnik/dist/
# cleanup symlink
rm ${TEMP_SYMLINK}
