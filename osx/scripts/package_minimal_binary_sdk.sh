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
${STAGING_DIR}/ 1>/dev/null
cp -r ${STAGING_DIR}/boost ${LOCAL_TARGET}/include/

# icu
cp -r ${BUILD}/include/unicode ${LOCAL_TARGET}/include/

cd ${MAPNIK_DIST}
rm -f ./${PACKAGE_NAME}*.tar.bz2
FOUND_VERSION=`mapnik-config --version`

# symlink approach
echo "...creating tarball of mapnik-${FOUND_VERSION}${MAPNIK_DEV_POSTFIX}-${CODENAME}.tar.bz2"
ln -s ${MAPNIK_INSTALL} ${MAPNIK_DIST}/${PACKAGE_NAME}
tar cjfH ${MAPNIK_DIST}/mapnik-${FOUND_VERSION}${MAPNIK_DEV_POSTFIX}-${CODENAME}.tar.bz2 ${PACKAGE_NAME}/
# cleanup symlink
rm ${MAPNIK_DIST}/${PACKAGE_NAME}
