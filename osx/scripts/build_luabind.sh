#!/bin/bash
set -e -u -x

mkdir -p ${PACKAGES}
cd ${PACKAGES}

download luabind-${LUABIND_VERSION}.tar.gz

echoerr 'building luabind'

# disabled because I failed to get bjam working on linux:
#  https://gist.github.com/springmeyer/17d0a1a12d7d4bce74d4
: '
rm -rf luabind-${LUABIND_VERSION}
tar xf luabind-${LUABIND_VERSION}.tar.gz
cd luabind-${LUABIND_VERSION}
#wget https://gist.github.com/DennisOSRM/3728987/raw/052251fcdc23602770f6c543be9b3e12f0cac50a/Jamroot.diff
patch -N Jamroot ${PATCHES}/Jamroot.diff
#wget https://github.com/luabind/luabind/commit/3044a9053ac50977684a75c4af42b2bddb853fad.diff
patch -N luabind/detail/format_signature.hpp ${PATCHES}/3044a9053ac50977684a75c4af42b2bddb853fad.diff
#wget https://gist.github.com/DennisOSRM/a246514bf7d01631dda8/raw/0e83503dbf862ebfb6ac063338a6d7bca793f94d/object_rep.diff
patch -N luabind/detail/object_rep.hpp ${PATCHES}/object_rep.diff
BOOST_ROOT=../boost_${BOOST_VERSION2}-${ARCH_NAME}
# linux needs: sudo ln -s /usr/lib/x86_64-linux-gnu/liblua5.1.so /usr/lib/liblua.so
${BOOST_ROOT}/b2 \
  -d2 \
  --prefix=${BUILD} \
  architecture="${BOOST_ARCH}" \
  toolset="${BOOST_TOOLSET}" \
  link=static \
  variant=release \
  linkflags="${LDFLAGS}" \
  cxxflags="${CXXFLAGS}" \
  -sBOOST_ROOT=${BOOST_ROOT} \
  stage install
'

rm -rf luabind
git clone https://github.com/DennisOSRM/luabind.git
cd luabind
# avoid g++ being killed on travis
if [ "${TRAVIS:-false}" != false ]; then
    JOBS=2
fi
export OLD_LINK_FLAGS=${LINK_FLAGS}
export LINK_FLAGS="${STDLIB_LDFLAGS} ${LINK_FLAGS}"
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
export LINK_FLAGS=${OLD_LINK_FLAGS}

cd ${PACKAGES}
