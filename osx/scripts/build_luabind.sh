#!/bin/bash
set -e -u

mkdir -p ${PACKAGES}
cd ${PACKAGES}

echo '*building luabind*'
rm -rf luabind
git clone https://github.com/DennisOSRM/luabind.git
cd luabind
export OLD_LDFLAGS=${LDFLAGS}
export LDFLAGS="${STDLIB_LDFLAGS} ${LDFLAGS}"
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
export LDFLAGS=${OLD_LDFLAGS}
cd ${PACKAGES}

#check_and_clear_libs
