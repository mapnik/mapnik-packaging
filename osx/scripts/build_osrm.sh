#!/bin/bash
set -e -u

mkdir -p ${PACKAGES}
cd ${PACKAGES}

echo '*building OSRM*'
rm -rf Project-OSRM
git clone https://github.com/DennisOSRM/Project-OSRM.git -b develop --depth 1
cd Project-OSRM
export OLD_LINK_FLAGS=${LINK_FLAGS}
export LINK_FLAGS="${STDLIB_LDFLAGS} ${LINK_FLAGS}"
mkdir build
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

#check_and_clear_libs
