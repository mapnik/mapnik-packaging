cd "$( dirname $( dirname "$0" ))"
source MacOSX.sh
# update mapnik
cd mapnik
echo 'pulling from git'
git pull
echo
echo

echo 'checking if we should rebuild'
if [ `git rev-list --max-count=1 HEAD` == `mapnik-config --git-revision` ]; then
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
cd scripts/
./build_mapnik_minimal.sh
./package_minimal_binary_sdk.sh