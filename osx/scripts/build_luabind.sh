#!/bin/bash
set -e -u

mkdir -p ${PACKAGES}
cd ${PACKAGES}

echoerr 'building luabind'

#download luabind-${LUABIND_VERSION}.tar.gz

rm -rf luabind
git clone --quiet --depth=0 https://github.com/DennisOSRM/luabind.git
cd luabind
git checkout 98f9ea861f58842c54aa9ebe7754659cc787a89c
# avoid g++ being killed on travis
if [ "${TRAVIS_COMMIT:-false}" != false ]; then
    JOBS=2
fi
LINK_FLAGS="${STDLIB_LDFLAGS} ${LINK_FLAGS}"
rm -rf build
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

cd ${PACKAGES}
