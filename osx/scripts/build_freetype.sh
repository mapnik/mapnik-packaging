#!/bin/bash
set -e -u

mkdir -p ${PACKAGES}
cd ${PACKAGES}

download freetype-${FREETYPE_VERSION}.tar.bz2

echoerr 'building freetype'
rm -rf freetype-${FREETYPE_VERSION}
tar xf freetype-${FREETYPE_VERSION}.tar.bz2
if [[ "${DISABLE_CFF:-false}" == true ]]; then
    CFLAGS="${CFLAGS} -DCFF_CONFIG_OPTION_OLD_ENGINE"
    echoerr "disabling freetype CFF"
else
    echoerr "keepin freetype CFF"
fi

cd freetype-${FREETYPE_VERSION}
./configure --prefix=${BUILD} --enable-static --disable-shared ${HOST_ARG} \
 --without-bzip2 \
 --without-png
make -j${JOBS}
make install
cd ${PACKAGES}
