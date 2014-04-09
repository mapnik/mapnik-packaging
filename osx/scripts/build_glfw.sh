#!/bin/bash
set -e -u
set -o pipefail
mkdir -p ${PACKAGES}
cd ${PACKAGES}

echoerr 'building glfw'

rm -rf glfw-master
git clone --quiet https://github.com/glfw/glfw.git glfw-master
cd glfw-master

rm -rf build
mkdir build
cd build
cmake ../ -DCMAKE_INSTALL_PREFIX=${BUILD} \
  -DCMAKE_C_COMPILER_ENV_VAR=${CC} \
  -DCMAKE_INCLUDE_PATH=${BUILD}/include \
  -DCMAKE_LIBRARY_PATH=${BUILD}/lib \
  -DBUILD_STATIC_LIBS=ON \
  -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_BUILD_TYPE=Release

make -j${JOBS} VERBOSE=1
make install

cd ${PACKAGES}
