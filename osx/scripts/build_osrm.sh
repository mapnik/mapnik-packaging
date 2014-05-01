#!/usr/bin/env bash
set -e -u
set -o pipefail
mkdir -p ${PACKAGES}
cd ${PACKAGES}

if [[ "${OSRM_COMMIT:-false}" == false ]]; then
    OSRM_COMMIT=a1ecab2f95b8bb157b03f49bd067099c9dc8664c
fi

if [[ "${OSRM_BRANCH:-false}" == false ]]; then
    OSRM_BRANCH=develop
fi

if [[ "${OSRM_REPO:-false}" == false ]]; then
    OSRM_REPO="https://github.com/DennisOSRM/Project-OSRM.git"
fi

echoerr 'building OSRM'
rm -rf Project-OSRM
git clone --quiet ${OSRM_REPO} -b $OSRM_BRANCH Project-OSRM
cd Project-OSRM
git checkout $OSRM_COMMIT

if [[ "${TRAVIS_COMMIT:-false}" != false ]]; then
    JOBS=2
fi

LINK_FLAGS="${STDLIB_LDFLAGS} ${LINK_FLAGS}"

if [[ ${PLATFORM} == 'Linux' ]]; then
    # workaround undefined reference to 'clock_gettime' when linking osrm-extract
    if [[ ${CXX} == "clang++" ]]; then
        LINK_FLAGS="-lrt ${LINK_FLAGS}"
    fi
fi

if [[ ${CXX11} == true ]]; then
    STDLIB_OVERRIDE=""
else
    STDLIB_OVERRIDE="-DOSXLIBSTD=\"libstdc++\""
fi

rm -rf build
mkdir -p build
cd build
cmake ../ -DCMAKE_INSTALL_PREFIX=${BUILD} \
  -DBoost_NO_SYSTEM_PATHS=ON \
  -DCMAKE_INCLUDE_PATH=${BUILD}/include \
  -DCMAKE_LIBRARY_PATH=${BUILD}/lib \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_EXE_LINKER_FLAGS="${LINK_FLAGS}" \
  ${STDLIB_OVERRIDE}

$MAKE -j${JOBS} VERBOSE=1
$MAKE install
cd ${PACKAGES}
