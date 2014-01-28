#!/bin/bash
set -e -u

mkdir -p ${PACKAGES}
cd ${PACKAGES}

if [[ "${OSRM_COMMIT:-false}" == false ]]; then
    OSRM_COMMIT=40517e3010757bdbb
fi

if [[ "${OSRM_BRANCH:-false}" == false ]]; then
    OSRM_BRANCH=develop
fi

echoerr 'building OSRM'
rm -rf Project-OSRM
git clone --quiet --depth=0 https://github.com/DennisOSRM/Project-OSRM.git -b $OSRM_BRANCH
cd Project-OSRM
git checkout $OSRM_COMMIT

if [[ "${TRAVIS_COMMIT:-false}" != false ]]; then
    JOBS=2
fi

LINK_FLAGS="${STDLIB_LDFLAGS} ${LINK_FLAGS}"

if [[ ${PLATFORM} == 'Linux' ]]; then
    # workaround undefined reference to `clock_gettime' when linking osrm-extract
    if [[ ${CXX} == "clang++" ]]; then
        LINK_FLAGS="-lrt ${LINK_FLAGS}"
    fi
fi

rm -rf build
mkdir -p build
cd build
cmake ../ -DCMAKE_INSTALL_PREFIX=${BUILD} \
  -DBoost_NO_SYSTEM_PATHS=ON \
  -DCMAKE_INCLUDE_PATH=${BUILD}/include \
  -DCMAKE_LIBRARY_PATH=${BUILD}/lib \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_EXE_LINKER_FLAGS="${LINK_FLAGS}"

make -j${JOBS} VERBOSE=1
make install
cd ${PACKAGES}
