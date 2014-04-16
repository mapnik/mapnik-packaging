#!/bin/bash
set -e -u
set -o pipefail
mkdir -p ${PACKAGES}
cd ${PACKAGES}

echoerr 'building glfw'

if [ ! -d 'glfw-master' ]; then
  git clone --quiet --depth=1 https://github.com/glfw/glfw.git glfw-master
fi

cd glfw-master
git pull

rm -rf build
mkdir build
cd build
cmake ../ -DCMAKE_INSTALL_PREFIX=${BUILD} \
  -DCMAKE_C_COMPILER_ENV_VAR=${CC} \
  -DCMAKE_INCLUDE_PATH=${BUILD}/include \
  -DCMAKE_LIBRARY_PATH=${BUILD}/lib \
  -DBUILD_SHARED_LIBS=OFF \
  -DGLFW_BUILD_DOCS=OFF \
  -DGLFW_BUILD_TESTS=OFF \
  -DGLFW_BUILD_EXAMPLES=OFF \
  -DCMAKE_BUILD_TYPE=Release

make -j${JOBS} VERBOSE=1
make install

cd ${PACKAGES}
