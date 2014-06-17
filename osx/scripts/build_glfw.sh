#!/usr/bin/env bash
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

GLFW_SHARED_FLAGS="-DCMAKE_INSTALL_PREFIX=${BUILD}\
  -DCMAKE_C_COMPILER=${CC} \
  -DCMAKE_CXX_COMPILER=${CXX} \
  -DCMAKE_INCLUDE_PATH=${BUILD}/include \
  -DCMAKE_LIBRARY_PATH=${BUILD}/lib \
  -DBUILD_SHARED_LIBS=OFF \
  -DGLFW_BUILD_DOCS=OFF \
  -DGLFW_BUILD_TESTS=OFF \
  -DGLFW_BUILD_EXAMPLES=OFF \
  -DCMAKE_BUILD_TYPE=Release \
  "

if [[ $BOOST_ARCH == "arm" ]]; then
  cmake ../ ${GLFW_SHARED_FLAGS} \
    -DCMAKE_FIND_ROOT_PATH=${SYSROOT} \
    -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER \
    -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY \
    -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY \
    -DGLFW_CLIENT_LIBRARY=glesv2 \
    -DGLFW_USE_EGL=ON
else
  cmake ../ ${GLFW_SHARED_FLAGS}
fi

$MAKE -j${JOBS} VERBOSE=1
$MAKE install

cd ${PACKAGES}
