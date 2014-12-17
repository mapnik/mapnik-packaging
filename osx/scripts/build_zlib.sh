#!/usr/bin/env bash
set -e -u
set -o pipefail
mkdir -p ${PACKAGES}
cd ${PACKAGES}

if [[ ${SHARED_ZLIB} == true ]]; then
    echoerr 'skipping zlib install, using shared lib'
else
    download zlib-${ZLIB_VERSION}.tar.gz
    echo 'building zlib'
    rm -rf zlib-${ZLIB_VERSION}
    tar xf zlib-${ZLIB_VERSION}.tar.gz
    cd zlib-${ZLIB_VERSION}
    if [[ ${MASON_PLATFORM} == 'Android' ]]; then
        patch -N < ${PATCHES}/android-zlib.diff
    fi
    if [[ ${MASON_PLATFORM} == 'nacl' ]]; then
        patch -N -p1 < ${PATCHES}/zlib-nacl.diff || true
        uname=${ARCH_NAME} ./configure --prefix=${BUILD} --static
    else
        ./configure --prefix=${BUILD} --static
    fi
    $MAKE -j$JOBS
    $MAKE install
    cd ${PACKAGES}

    #check_and_clear_libs
fi
