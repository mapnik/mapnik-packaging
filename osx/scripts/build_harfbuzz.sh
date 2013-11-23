#!/bin/bash
set -e -u

mkdir -p ${PACKAGES}
cd ${PACKAGES}

# proj4
echo '*building harfbuzz*'
rm -rf harfbuzz-${HARFBUZZ_VERSION}
tar xf harfbuzz-${HARFBUZZ_VERSION}.tar.bz2
cd harfbuzz-${HARFBUZZ_VERSION}
export OLD_LDFLAGS=${LDFLAGS}
export CXXFLAGS="${CXXFLAGS} -DHB_NO_MT"
export CFLAGS="${CFLAGS} -DHB_NO_MT"
export LDFLAGS="${STDLIB_LDFLAGS} ${LDFLAGS}"
./configure --prefix=${BUILD} ${HOST_ARG} \
 --enable-static --disable-shared --disable-dependency-tracking \
 --with-icu \
 --with-cairo=no \
 --with-glib=no \
 --with-gobject=no \
 --with-graphite2=no \
 --with-freetype \
 --with-uniscribe=no \
 --with-coretext=no
make -j${JOBS}
make install
export LDFLAGS=${OLD_LDFLAGS}
cd ${PACKAGES}
