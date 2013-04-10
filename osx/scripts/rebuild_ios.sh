set -e
cd "$( dirname $( dirname "$0" ))"
# update mapnik
cd mapnik
echo 'pulling from git'
git pull
echo
echo
cd ../

echo 'checking if we should rebuild'
if [ `git rev-list --max-count=1 HEAD` == `mapnik-config --git-revision` ]; then
  echo "Version unchanged, aborting build"
  #exit 0
else
  echo "new build detected, carrying on"
fi

# x86_64
source MacOSX.sh
# required for bcp header copy
./scripts/build_core_deps.sh
./scripts/build_protobuf.sh
./scripts/build_mapnik_ios.sh

source iPhoneOS.sh
./scripts/build_core_deps.sh
./scripts/build_protobuf.sh
./scripts/build_mapnik_ios.sh

# armv7s
source iPhoneOSs.sh
./scripts/build_core_deps.sh
./scripts/build_protobuf.sh
./scripts/build_mapnik_ios.sh

# i386
source iPhoneSimulator.sh
./scripts/build_core_deps.sh
./scripts/build_protobuf.sh
./scripts/build_mapnik_ios.sh

# done now package
./scripts/make_universal.sh
# TODO 
./scripts/package_ios_sdk.sh
