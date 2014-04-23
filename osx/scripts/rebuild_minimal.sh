#!/bin/bash
set -e -u
set -o pipefail
cd "$( dirname $( dirname "$0" ))"
source MacOSX.sh
# update mapnik
cd mapnik
echo 'pulling from git'
git pull
echo
echo

echo 'checking if we should rebuild'
if [[ $(git rev-list --max-count=1 HEAD) == $(${MAPNIK_CONFIG} --git-revision) ]]; then
  echo "Version unchanged, aborting build"
  exit 0
else
  echo "new build detected, carrying on"
fi

echo 'cleaning and uninstalling old build'
make clean
make uninstall
cd ../

rm -rf ${MAPNIK_BIN_SOURCE}
./scripts/build_protobuf.sh
./scripts/build_mapnik_minimal.sh
./scripts/package_minimal_binary_sdk.sh