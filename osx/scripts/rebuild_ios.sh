#!/bin/bash
set -e -u

cd "$( dirname $( dirname "$0" ))"
# update mapnik
cd mapnik
echo 'pulling from git'
#git pull
echo
echo
cd ../

echo 'checking if we should rebuild'
if [ `git rev-list --max-count=1 HEAD` == `${MAPNIK_CONFIG} --git-revision` ]; then
  echo "Version unchanged, aborting build"
  #exit 0
else
  echo "new build detected, carrying on"
fi

BUILD_DEPS=false

function build_all {
  if [ $BUILD_DEPS = true ];  then
    ./scripts/build_core_deps.sh
    ./scripts/build_protobuf.sh
  fi
  ./scripts/build_mapnik_mobile.sh
}

# x86_64
source MacOSX.sh
# required for bcp header copy
build_all

# i386
source iPhoneSimulator.sh
# required first for cross compiling later on arm
build_all

# armv7
source iPhoneOS.sh
build_all

# armv7s
source iPhoneOSs.sh
build_all

# done now package
./scripts/make_universal.sh
# TODO 
./scripts/package_mobile_sdk.sh
