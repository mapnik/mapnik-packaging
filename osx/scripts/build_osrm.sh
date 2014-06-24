#!/usr/bin/env bash
set -e -u
set -o pipefail
mkdir -p ${PACKAGES}
cd ${PACKAGES}

if [[ "${OSRM_COMMIT:-false}" == false ]]; then
    OSRM_COMMIT=547455245e7fe6346386574f6c61e4863540dee9
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
git apply ${PATCHES}/osrm-rt.diff || true

if [[ "${TRAVIS_COMMIT:-false}" != false ]]; then
    JOBS=2
fi

LINK_FLAGS="${STDLIB_LDFLAGS} ${LINK_FLAGS}"

# http://www.cmake.org/pipermail/cmake/2009-May/029375.html
# http://stackoverflow.com/questions/16991225/cmake-and-static-linking
if [[ ${PLATFORM} == 'Linux' ]]; then
    LINK_FLAGS="-fopenmp ${LINK_FLAGS} "'-Wl,-z,origin -Wl,-rpath=\$ORIGIN'
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
  -DCMAKE_CXX_COMPILER="$CXX" \
  -DBoost_NO_SYSTEM_PATHS=ON \
  -DTBB_INSTALL_DIR=${BUILD} \
  -DCMAKE_INCLUDE_PATH=${BUILD}/include \
  -DCMAKE_LIBRARY_PATH=${BUILD}/lib \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_EXE_LINKER_FLAGS="${LINK_FLAGS}" \
  ${STDLIB_OVERRIDE}

$MAKE -j${JOBS} VERBOSE=1
$MAKE install
cd ${PACKAGES}
