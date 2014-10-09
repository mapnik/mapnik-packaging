#!/usr/bin/env bash
set -e -u
set -o pipefail
mkdir -p ${PACKAGES}
cd ${PACKAGES}

echoerr 'building luabind'


if [[ "${LUABIND_COMMIT:-false}" == false ]]; then
    LUABIND_COMMIT=2b904b3042c2fa0682f4adcd42ee91b6af48a924
fi

if [[ "${LUABIND_BRANCH:-false}" == false ]]; then
    LUABIND_BRANCH=develop
fi

if [[ "${LUABIND_REPO:-false}" == false ]]; then
    LUABIND_REPO="https://github.com/DennisOSRM/luabind.git"
fi

echoerr 'building OSRM'
rm -rf luabind
git clone --quiet ${LUABIND_REPO} -b $LUABIND_BRANCH luabind
cd luabind
git checkout $LUABIND_COMMIT

if [[ "${TRAVIS_COMMIT:-false}" != false ]]; then
    if [[ "${CXX#*'clang'}" != "$CXX" ]]; then
        JOBS=4
    else
        JOBS=2
    fi
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
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_TESTING=OFF \
  ${STDLIB_OVERRIDE}

$MAKE -j${JOBS} VERBOSE=1
$MAKE install

cd ${PACKAGES}
