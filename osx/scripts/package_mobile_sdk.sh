#!/bin/bash
set -e -u

echoerr '...packaging mobile sdk tarball'

# where we are headed
mkdir -p ${MAPNIK_DIST}
cd ${MAPNIK_DIST}
DESCRIBE=`mapnik-config --git-describe`
# collapse all iOS platform names to one since
# we provide these multiarch
if test "${platform#*'iphone'}" != "$platform"; then
    platform="ios"
fi
PACKAGE_NAME="${MAPNIK_PACKAGE_PREFIX}-${platform}-sdk-${DESCRIBE}-${CXX_STANDARD}-${STDLIB}"
LOCAL_TARGET="${MAPNIK_DIST}/${PACKAGE_NAME}"
TARBALL_NAME="${PACKAGE_NAME}.tar"
mkdir -p "${LOCAL_TARGET}"
STAGING_DIR="boost-staging-minimal"

# clear up where we're going
rm -rf ${LOCAL_TARGET}/* || rm -rf ${LOCAL_TARGET}/*

echoerr '...creating base directories'

mkdir ${LOCAL_TARGET}/lib
mkdir ${LOCAL_TARGET}/include
mkdir ${LOCAL_TARGET}/share/
mkdir ${LOCAL_TARGET}/bin
mkdir -p ${LOCAL_TARGET}/lib/pkgconfig

if [ -d "${MAPNIK_BIN_SOURCE}/share" ]; then
    cp -r "${MAPNIK_BIN_SOURCE}/share" "${LOCAL_TARGET}/share"
fi

sed -e "s=$BUILD=\$CONFIG_PREFIX=g" "${MAPNIK_BIN_SOURCE}/bin/mapnik-config" > "${LOCAL_TARGET}/bin/mapnik-config"
chmod +x "${LOCAL_TARGET}/bin/mapnik-config"
cp -r "${MAPNIK_BIN_SOURCE}/include/mapnik" "${LOCAL_TARGET}/include/mapnik"
if [ -d "${MAPNIK_BIN_SOURCE}/lib/mapnik/input/" ];then
  mkdir -p "${LOCAL_TARGET}/lib/mapnik/input/"
  cp -r "${MAPNIK_BIN_SOURCE}/lib/mapnik/input" "${LOCAL_TARGET}/lib/mapnik/input"
fi

echoerr '...packaging boost headers'
# TODO - make finding bcp more robust
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
boost/gil/gil_all.hpp \
${STAGING_DIR}/ 1>/dev/null
cp -r ${STAGING_DIR}/boost ${LOCAL_TARGET}/include/
cd ${MAPNIK_DIST}

echoerr "*copying other headers*"
# icu
cp -r ${BUILD}/include/unicode ${LOCAL_TARGET}/include/

# jpeg
cp -r ${BUILD}/include/j* ${LOCAL_TARGET}/include/

# png
cp -r ${BUILD}/include/p* ${LOCAL_TARGET}/include/

# zlib
if [[ $SHARED_ZLIB != true ]]; then
    cp -r ${BUILD}/include/z* ${LOCAL_TARGET}/include/
fi

# cairo
if [ -d ${BUILD}/include/cairo ];then
  cp -r ${BUILD}/include/cairo ${LOCAL_TARGET}/include/
fi

# protobuf
echoerr '...copying over protobuf'
if [[ `which protoc` ]]; then
    cp `which protoc` ${LOCAL_TARGET}/bin/
fi
mkdir -p ${LOCAL_TARGET}/include/google/protobuf
cp -r ${BUILD}/include/google/protobuf ${LOCAL_TARGET}/include/google/protobuf
cp ${BUILD}/lib/pkgconfig/protobuf.pc ${LOCAL_TARGET}/lib/pkgconfig/
cp ${BUILD}/lib/libprotobuf-lite* ${LOCAL_TARGET}/lib/
#cp -r ${BUILD}/lib/pkgconfig/protobuf-lite.pc ${LOCAL_TARGET}/lib/pkgconfig


# multiarch mapnik libs
if [ -d "${BUILD_UNIVERSAL}/" ]; then
    cp ${BUILD_UNIVERSAL}/* ${LOCAL_TARGET}/lib/
else
    cp ${MAPNIK_BIN_SOURCE}/lib/libmapnik.* ${LOCAL_TARGET}/lib/
fi
cd ${MAPNIK_DIST}
rm -f ./${TARBALL_NAME}*
echo ${DESCRIBE} > ${LOCAL_TARGET}/VERSION
echo "Produced on `date`" >> ${LOCAL_TARGET}/VERSION

echoerr "...creating tarball of mapnik build"
# -j bz2
# -c compress
# -f write to file
# -H symbolic links are followed/materialized (but linux itis -h)
time tar -c -j -f "${MAPNIK_DIST}/${TARBALL_NAME}.bz2" "${PACKAGE_NAME}/"
ls -lh *tar*
# -z compress
# -k keep
# --best high compression
# 20 MB
#time bzip2 -z -k --best ${TARBALL_NAME}

# 13 MB
#time xz -z -k -e -9 ${TARBALL_NAME}
if [ $OFFICIAL_RELEASE = 'true' ]; then
  UPLOAD="s3://mapnik/dist/v${DESCRIBE}/${TARBALL_NAME}.bz2"
else
  UPLOAD="s3://mapnik/dist/dev/${TARBALL_NAME}.bz2"
fi
echoerr "*uploading ${UPLOAD}"
ensure_s3cmd
s3cmd --acl-public put ${MAPNIK_DIST}/${TARBALL_NAME}.bz2 ${UPLOAD}
s3cmd ls `dirname s3://mapnik/dist/dev/*/*`
# update https://gist.github.com/springmeyer/eab2ff20ac560fbb9dd9
