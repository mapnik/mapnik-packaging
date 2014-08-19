#!/usr/bin/env bash
set -e -u
set -o pipefail
mkdir -p ${PACKAGES}
cd ${PACKAGES}

download stxxl-${STXXL_VERSION}.tar.gz

echoerr 'building libsxxl'
rm -rf stxxl-${STXXL_VERSION}
rm -rf stxxl-${STXXL_VERSION}-${ARCH_NAME}
tar xf stxxl-${STXXL_VERSION}.tar.gz
mv stxxl-${STXXL_VERSION} stxxl-${STXXL_VERSION}-${ARCH_NAME}
cd stxxl-${STXXL_VERSION}-${ARCH_NAME}
LINK_FLAGS="${STDLIB_LDFLAGS} ${LINK_FLAGS}"
mkdir build
cd build
if [ ${CXX11} = true ]; then
    CXX_ENABLED="-DNO_CXX11=OFF"
else
    CXX_ENABLED="-DNO_CXX11=ON"
fi
cmake ../ -DCMAKE_INSTALL_PREFIX=${BUILD} \
  -DBUILD_STATIC_LIBS=ON \
  -DUSE_GNU_PARALLEL=OFF \
  -DCMAKE_BUILD_TYPE=Release \
  ${CXX_ENABLED}
$MAKE -j${JOBS} VERBOSE=1
$MAKE install
cd ${PACKAGES}

##check_and_clear_libs
