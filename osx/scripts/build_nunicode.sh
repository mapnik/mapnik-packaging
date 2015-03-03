#!/usr/bin/env bash
set -e -u
set -o pipefail
mkdir -p ${PACKAGES}
cd ${PACKAGES}

echoerr 'building nunicode'

rm -rf nunicode
git clone --quiet --depth=1 https://bitbucket.org/alekseyt/nunicode.git
cd nunicode
git checkout 72f7dbe22bb7b2275c9bd95c4470a17d5a422809

# use builddir instead of build because there is already a file with this name
rm -rf builddir
mkdir builddir
cd builddir

cmake ../ -DCMAKE_INSTALL_PREFIX=${BUILD} \
  -DCMAKE_INCLUDE_PATH=${BUILD}/include \
  -DCMAKE_LIBRARY_PATH=${BUILD}/lib \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_DISABLE_FIND_PACKAGE_Sqlite3=TRUE

$MAKE nu -j${JOBS} VERBOSE=1
$MAKE install

cd ${PACKAGES}
