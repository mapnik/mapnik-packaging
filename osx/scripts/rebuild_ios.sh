#!/usr/bin/env bash
set -e -u
set -o pipefail

export CXX11=true
source iPhoneOS.sh

cd "$( dirname $( dirname "$0" ))"

branch="2.2.x"
if [ ! -d ${MAPNIK_SOURCE} ]; then
  git clone --quiet https://github.com/mapnik/mapnik.git ${MAPNIK_SOURCE} -b $branch
  git branch -v
fi

# update mapnik
cd ${MAPNIK_SOURCE}
echo 'pulling from git'
#git pull
echo
echo
cd ../

echo 'checking if we should rebuild'
if [[ $(git rev-list --max-count=1 HEAD) == $(${MAPNIK_CONFIG} --git-revision) ]]; then
  echo "Version unchanged, aborting build"
  #exit 0
else
  echo "new build detected, carrying on"
fi

BUILD_DEPS=true

function build_all {
  if [ $BUILD_DEPS = true ];  then
    ./scripts/build_freetype.sh
    ./scripts/build_icu.sh
    ./scripts/build_protobuf.sh
    BOOST_LIBRARIES="--with-thread --with-filesystem --disable-filesystem2 --with-system --with-regex"
    ./scripts/build_boost.sh ${BOOST_LIBRARIES}
    ./scripts/build_jpeg.sh
    ./scripts/build_png.sh
    ./scripts/build_libxml2.sh
    ./scripts/build_pkg_config.sh
    ./scripts/build_bzip2.sh
    ./scripts/build_zlib.sh
  fi
  ./scripts/build_mapnik_mobile.sh
}

# # x86_64
# source MacOSX.sh
# # required for bcp header copy
# build_all

# 32-bit simulator
source iPhoneSimulator.sh
# required first for cross compiling later on arm
build_all

# 64-bit simulator
source iPhoneSimulator64.sh
# required first for cross compiling later on arm
build_all

# armv7
source iPhoneOS.sh
build_all

# armv7s
source iPhoneOSs.sh
build_all

# armv64
source iPhoneOS64.sh
build_all

# done now package
./scripts/make_universal.sh
# TODO
#./scripts/package_mobile_sdk.sh
