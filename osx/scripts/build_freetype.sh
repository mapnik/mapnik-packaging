#!/usr/bin/env bash
set -e -u
set -o pipefail
mkdir -p ${PACKAGES}
cd ${PACKAGES}

download freetype-${FREETYPE_VERSION}.tar.bz2

echoerr 'building freetype'
rm -rf freetype-${FREETYPE_VERSION}
tar xf freetype-${FREETYPE_VERSION}.tar.bz2

cd freetype-${FREETYPE_VERSION}
# workaround freetype 2.6.1 glitch
if [[ ${FREETYPE_VERSION} == "2.6.1" ]]; then
    ln -s builds/unix/install-sh .
fi
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

$MAKE -j${JOBS}
$MAKE install
cd ${PACKAGES}
