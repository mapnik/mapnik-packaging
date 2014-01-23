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

if [[ ${OFFICIAL_RELEASE} == true ]]; then
  PACKAGE_NAME="${MAPNIK_PACKAGE_PREFIX}-${platform}-sdk-${DESCRIBE}"
  TARBALL_NAME="${PACKAGE_NAME}.tar"
  UPLOAD="s3://mapnik/dist/v${DESCRIBE}/${TARBALL_NAME}.bz2"
else
  PACKAGE_NAME="${MAPNIK_PACKAGE_PREFIX}-${platform}-sdk-${DESCRIBE}-${CXX_STANDARD}-${STDLIB}-${CXX_NAME}"
  TARBALL_NAME="${PACKAGE_NAME}.tar"
  UPLOAD="s3://mapnik/dist/dev/${TARBALL_NAME}.bz2"
fi

LOCAL_TARGET="${MAPNIK_DIST}/${PACKAGE_NAME}"
mkdir -p "${LOCAL_TARGET}"
STAGING_DIR="boost-staging-minimal"

# clear up where we're going
rm -rf ${LOCAL_TARGET}/* || rm -rf ${LOCAL_TARGET}/*

echoerr '...creating base directories'

mkdir ${LOCAL_TARGET}/lib
mkdir ${LOCAL_TARGET}/include
mkdir ${LOCAL_TARGET}/bin
mkdir -p ${LOCAL_TARGET}/lib/pkgconfig
mkdir ${LOCAL_TARGET}/share/

# NOTE: linux cp command needs the trailing dir names not to match otherwise it will nest the result
# NOTE: OS X cp needs the from dir not to have a trailing slash otherwise it moves what is inside instead of the dir
if [ -d "${MAPNIK_BIN_SOURCE}/share" ]; then
    cp -r "${MAPNIK_BIN_SOURCE}/share/mapnik" "${LOCAL_TARGET}/share/"
fi

sed -e "s=$BUILD=\$CONFIG_PREFIX=g" "${MAPNIK_BIN_SOURCE}/bin/mapnik-config" > "${LOCAL_TARGET}/bin/mapnik-config"
chmod +x "${LOCAL_TARGET}/bin/mapnik-config"
cp -r "${MAPNIK_BIN_SOURCE}/include/mapnik" "${LOCAL_TARGET}/include/"
if [ -d "${MAPNIK_BIN_SOURCE}/lib/mapnik/input/" ];then
    mkdir -p "${LOCAL_TARGET}/lib/mapnik/input/"
    cp -r "${MAPNIK_BIN_SOURCE}/lib/mapnik/input" "${LOCAL_TARGET}/lib/mapnik/"
fi

BCP_TOOL=$(find ${PACKAGES}/boost*/dist/* -name 'bcp' -print -quit)
if [ $BCP_TOOL ]; then
    echoerr 'packaging boost headers'
    # http://www.boost.org/doc/libs/1_55_0b1/tools/bcp/doc/html/index.html
    cd ${PACKAGES}/boost_${BOOST_VERSION2}-${ARCH_NAME}/
    rm -rf ${STAGING_DIR}/*
    mkdir -p ${STAGING_DIR}
    if [[ $UNAME == 'Linux' ]]; then
         # workaround
         # **** exception(205): std::exception: basic_filebuf::underflow error reading the file
         # ******** errors detected; see standard output for details ********
        # 53 MB
        ./dist/bin/bcp ${MAPNIK_BIN_SOURCE}/include ${STAGING_DIR} 1>/dev/null
        # 43 MB
        #./dist/bin/bcp --scane ${MAPNIK_BIN_SOURCE}/include/mapnik/*hpp ${STAGING_DIR} 1>/dev/null
    else
        ./dist/bin/bcp --scan \
        `find ${MAPNIK_BIN_SOURCE}/include -type d | sed 's/$/\/*/' | tr '\n' ' '` \
        ${STAGING_DIR} 1>/dev/null
    fi
    du -h -d 0 boost-staging-minimal/boost/
    cp -r ${STAGING_DIR}/boost ${LOCAL_TARGET}/include/
else
    echoerr 'could not find boost bcp'
    exit 1
fi

cd ${MAPNIK_DIST}

echoerr "copying headers of other deps"

# icu
if [ -d ${BUILD}/include/unicode ]; then
    echo "copying icu"
    cp -r ${BUILD}/include/unicode ${LOCAL_TARGET}/include/
fi

# webp
if [ -d ${BUILD}/include/webp ]; then
    echo "copying webp"
    cp -r ${BUILD}/include/webp ${LOCAL_TARGET}/include/
fi

# harfbuzz
if [ -d ${BUILD}/include/harfbuzz ]; then
    echo "copying harfbuzz"
    cp -r ${BUILD}/include/harfbuzz ${LOCAL_TARGET}/include/
fi

# jpeg - optional
for i in $(find ${BUILD}/include/ -maxdepth 1 -name 'j*.*' -print); do
    echo "copying jpeg: $i"
    cp $i ${LOCAL_TARGET}/include/
done;

# png - optional
for i in $(find ${BUILD}/include/ -maxdepth 1 -name 'png*.*' -print); do
    echo "copying png: $i"
    cp $i ${LOCAL_TARGET}/include/
done;

# tiff - optional
for i in $(find ${BUILD}/include/ -maxdepth 1 -name 'tiff*.*' -print); do
    echo "copying tiff: $i"
    cp $i ${LOCAL_TARGET}/include/
done;

# proj - optional
for i in $(find ${BUILD}/include/ -maxdepth 1 -name 'proj*.*' -print); do
    echo "copying proj: $i"
    cp $i ${LOCAL_TARGET}/include/
done;

# bzlib
for i in $(find ${BUILD}/include/ -maxdepth 1 -name 'bzlib.*' -print); do
    echo "copying bz2: $i"
    cp $i ${LOCAL_TARGET}/include/
done;

# zlib - optional
if [[ $SHARED_ZLIB != true ]]; then
    for i in $(find ${BUILD}/include/ -maxdepth 1 -name 'z*.*' -print); do
        echo "copying zlib: $i"
        cp $i ${LOCAL_TARGET}/include/
    done;
    if [ -f "${BUILD}/lib/libz.a" ]; then
        cp "${BUILD}/lib/libz.a" ${LOCAL_TARGET}/lib/
    fi
fi

# cairo
if [ -d ${BUILD}/include/cairo ];then
    echo 'copying cairo'
    cp -r ${BUILD}/include/cairo ${LOCAL_TARGET}/include/
fi

# protobuf - optional
if [ -d ${BUILD}/include/google ]; then
    echo 'copying protobuf'
    # NOTE: using which here to get the non arm version
    if [[ `which protoc` ]]; then
        cp `which protoc` ${LOCAL_TARGET}/bin/
    fi
    mkdir -p ${LOCAL_TARGET}/include/google/protobuf
    cp -r ${BUILD}/include/google/protobuf ${LOCAL_TARGET}/include/google/
    cp ${BUILD}/lib/pkgconfig/protobuf.pc ${LOCAL_TARGET}/lib/pkgconfig/
    cp "${BUILD}/lib/libprotobuf-lite.a" ${LOCAL_TARGET}/lib/
fi

if [ -d "${BUILD_UNIVERSAL}" ]; then
    echoerr "copying universal libs"
    # multiarch mapnik libs
    cp ${BUILD_UNIVERSAL}/* ${LOCAL_TARGET}/lib/
else
    # just mapnik single arch
    echoerr "copying mapnik"
    cp ${MAPNIK_BIN_SOURCE}/lib/libmapnik.* ${LOCAL_TARGET}/lib/
    echoerr "copying libs of other deps"
    for i in $(mapnik-config --dep-libs | sed 's/-l//g'); do
        if [ -f "${BUILD}/lib/lib${i}.a" ]; then
            cp "${BUILD}/lib/lib${i}.a" "${LOCAL_TARGET}/lib/lib${i}.a"
        fi
    done
fi

cd ${MAPNIK_DIST}
rm -f ./${TARBALL_NAME}*
echo ${DESCRIBE} > ${LOCAL_TARGET}/VERSION
echo `mapnik-config -v` >> ${LOCAL_TARGET}/VERSION
echo `mapnik-config --all-flags` >> ${LOCAL_TARGET}/VERSION
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
echoerr "*uploading ${UPLOAD}"
ensure_s3cmd
s3cmd --acl-public put ${MAPNIK_DIST}/${TARBALL_NAME}.bz2 ${UPLOAD}
s3cmd ls `dirname s3://mapnik/dist/dev/*/*`
# update https://gist.github.com/springmeyer/eab2ff20ac560fbb9dd9
