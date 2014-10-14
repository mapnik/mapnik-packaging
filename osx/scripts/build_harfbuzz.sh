#!/usr/bin/env bash
set -e -u
set -o pipefail
mkdir -p ${PACKAGES}
cd ${PACKAGES}

HARFBUZZ_LATEST=true

echoerr 'building harfbuzz'

if [[ ${HARFBUZZ_LATEST} == true ]]; then
    if [[ ! -d harfbuzz-master ]]; then
        git clone --quiet https://github.com/behdad/harfbuzz.git harfbuzz-master
        cd harfbuzz-master
        ./autogen.sh
        git checkout a1f27ac3c48cfe6d532dc422cf256952fea472ed
        git apply ${PATCHES}/harfbuzz-disable-pkg-config.diff
    else
        cd harfbuzz-master
        git checkout .
        git pull || true
        git checkout a1f27ac3c48cfe6d532dc422cf256952fea472ed
        git apply ${PATCHES}/harfbuzz-disable-pkg-config.diff
        # TODO - depends on ragel
        ./autogen.sh ${HOST_ARG}
        make clean
        make distclean
    fi
else
    download harfbuzz-${HARFBUZZ_VERSION}.tar.bz2
    rm -rf harfbuzz-${HARFBUZZ_VERSION}
    tar xf harfbuzz-${HARFBUZZ_VERSION}.tar.bz2
    cd harfbuzz-${HARFBUZZ_VERSION}
    patch -N -p1 < ${PATCHES}/harfbuzz-disable-pkg-config.diff || true
fi

FREETYPE_CFLAGS="-I${BUILD}/include/freetype2"
FREETYPE_LIBS="-L${BUILD}/lib -lfreetype -lz"
CXXFLAGS="${CXXFLAGS} -DHB_NO_MT ${FREETYPE_CFLAGS}"
CFLAGS="${CFLAGS} -DHB_NO_MT ${FREETYPE_CFLAGS}"
LDFLAGS="${STDLIB_LDFLAGS} ${LDFLAGS} ${FREETYPE_LIBS}"
./configure --prefix=${BUILD} ${HOST_ARG} \
 --enable-static --disable-shared --disable-dependency-tracking \
 --with-icu=no \
 --with-cairo=no \
 --with-glib=no \
 --with-gobject=no \
 --with-graphite2=no \
 --with-freetype \
 --with-uniscribe=no \
 --with-coretext=no
$MAKE -j${JOBS} V=1
$MAKE install
cd ${PACKAGES}
