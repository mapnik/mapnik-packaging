#!/usr/bin/env bash
set -e -u
set -o pipefail
mkdir -p ${PACKAGES}
cd ${PACKAGES}

if [[ "${LUABIND_COMMIT:-false}" == false ]]; then
    LUABIND_COMMIT=e414c57bcb687bb3091b7c55bbff6947f052e46b
fi

if [[ "${LUABIND_BRANCH:-false}" == false ]]; then
    LUABIND_BRANCH=master
fi

if [[ "${LUABIND_REPO:-false}" == false ]]; then
    LUABIND_REPO="https://github.com/DennisOSRM/luabind.git"
fi

echoerr 'building luabind'
rm -rf luabind
git clone ${LUABIND_REPO} luabind
cd luabind
git checkout .
git checkout $LUABIND_BRANCH
git checkout $LUABIND_COMMIT

if [[ "${TRAVIS_COMMIT:-false}" != false ]]; then
    if [[ "${CXX#*'clang'}" != "$CXX" ]]; then
        JOBS=4
    else
        JOBS=2
    fi
fi

LINK_FLAGS="${STDLIB_LDFLAGS} ${LINK_FLAGS}"

rm -rf build
mkdir build
cd build
cmake ../ -DCMAKE_INSTALL_PREFIX=${BUILD} \
  -DBoost_NO_SYSTEM_PATHS=ON \
  -DCMAKE_INCLUDE_PATH=${BUILD}/include \
  -DCMAKE_LIBRARY_PATH=${BUILD}/lib \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_TESTING=OFF \
  ${STDLIB_OVERRIDE}

$MAKE -j${JOBS} VERBOSE=1
$MAKE install

cd ${PACKAGES}
