#!/usr/bin/env bash
set -e -u
set -o pipefail
mkdir -p ${PACKAGES}
cd ${PACKAGES}

download freetype-${FREETYPE_VERSION}.tar.bz2

echoerr 'building freetype'
rm -rf freetype-${FREETYPE_VERSION}
tar xf freetype-${FREETYPE_VERSION}.tar.bz2
# http://sourceforge.net/projects/freetype/files/freetype2/2.5.0/
if [[ "${DISABLE_CFF:-false}" == true ]]; then
    CFLAGS="${CFLAGS} -DCFF_CONFIG_OPTION_OLD_ENGINE=1"
    echoerr "disabling freetype CFF"
else
    echoerr "keepin freetype CFF"
fi

cd freetype-${FREETYPE_VERSION}
# NOTE: --with-zlib=yes means external, non-bundled zip will be used
./configure --prefix=${BUILD} --enable-static --disable-shared ${HOST_ARG} \
 --with-zlib=yes \
 --with-bzip2=no \
 --with-harfbuzz=no \
 --with-png=no \
 --with-quickdraw-toolbox=no \
 --with-quickdraw-carbon=no \
 --with-ats=no \
 --with-fsref=no \
 --with-fsspec=no \

make -j${JOBS}
make install
cd ${PACKAGES}
