#!/usr/bin/env bash
set -e -u
set -o pipefail
mkdir -p ${PACKAGES}
cd ${PACKAGES}

HARFBUZZ_LATEST=false

echoerr 'building harfbuzz'

if [[ ${HARFBUZZ_LATEST} == true ]]; then
    if [[ ! -d harfbuzz-master ]]; then
        git clone git@github.com:behdad/harfbuzz.git harfbuzz-master
        cd harfbuzz-master
        ./autogen.sh
    else
        cd harfbuzz-master
        git checkout .
        git pull
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
fi

CXXFLAGS="${CXXFLAGS} -DHB_NO_MT"
CFLAGS="${CFLAGS} -DHB_NO_MT"
LDFLAGS="${STDLIB_LDFLAGS} ${LDFLAGS}"
# WARNING: freetype configure will fail silently unless pkg-config is installed
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
$MAKE -j${JOBS}
$MAKE install
cd ${PACKAGES}
