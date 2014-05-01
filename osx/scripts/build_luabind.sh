#!/usr/bin/env bash
set -e -u
set -o pipefail
mkdir -p ${PACKAGES}
cd ${PACKAGES}

echoerr 'building luabind'

#download luabind-${LUABIND_VERSION}.tar.gz

rm -rf luabind
git clone --quiet https://github.com/DennisOSRM/luabind.git
cd luabind
git checkout 789c9e0f98
# avoid g++ being killed on travis
if [[ "${TRAVIS_COMMIT:-false}" != false ]]; then
    JOBS=2
fi
LINK_FLAGS="${STDLIB_LDFLAGS} ${LINK_FLAGS}"

if [[ ${CXX11} == true ]]; then
    STDLIB_OVERRIDE=""
else
    STDLIB_OVERRIDE="-DOSXLIBSTD=\"libstdc++\""
fi

rm -rf build
mkdir build
cd build
cmake ../ -DCMAKE_INSTALL_PREFIX=${BUILD} \
  -DBoost_NO_SYSTEM_PATHS=ON \
  -DCMAKE_INCLUDE_PATH=${BUILD}/include \
  -DCMAKE_LIBRARY_PATH=${BUILD}/lib \
  -DBUILD_STATIC_LIBS=ON \
  -DCMAKE_BUILD_TYPE=Release \
  ${STDLIB_OVERRIDE}

$MAKE -j${JOBS} VERBOSE=1
$MAKE install

cd ${PACKAGES}
