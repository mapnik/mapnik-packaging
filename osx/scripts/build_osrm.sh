#!/bin/bash
set -e -u

mkdir -p ${PACKAGES}
cd ${PACKAGES}

echoerr 'building OSRM'
rm -rf Project-OSRM
git clone https://github.com/DennisOSRM/Project-OSRM.git -b develop --depth 1
cd Project-OSRM

if [ ${TRAVIS} = true ]; then
    JOBS=2
fi

export OLD_LINK_FLAGS=${LINK_FLAGS}
export LINK_FLAGS="${STDLIB_LDFLAGS} ${LINK_FLAGS}"

if [ ${PLATFORM} = 'Linux' ]; then
    # workaround undefined reference to `clock_gettime' when linking osrm-extract
    if [ ${CXX} = "clang++" ]; then
        export LINK_FLAGS="-lrt ${LINK_FLAGS}"
    fi
fi

rm -rf build
mkdir -p build
cd build
cmake ../ -DCMAKE_INSTALL_PREFIX=${BUILD} \
  -DBoost_NO_SYSTEM_PATHS=ON \
  -DCMAKE_INCLUDE_PATH=${BUILD}/include \
  -DCMAKE_LIBRARY_PATH=${BUILD}/lib \
  -DBUILD_STATIC_LIBS=ON \
  -DCMAKE_BUILD_TYPE=Release
make -j${JOBS} VERBOSE=1
make install
export LINK_FLAGS=${OLD_LINK_FLAGS}
cd ${PACKAGES}
