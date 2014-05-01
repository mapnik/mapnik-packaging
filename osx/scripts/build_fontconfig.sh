#!/usr/bin/env bash
set -e -u
set -o pipefail
mkdir -p ${PACKAGES}
cd ${PACKAGES}

download fontconfig-${FONTCONFIG_VERSION}.tar.bz2

# fontconfig
echoerr 'building fontconfig'
rm -rf fontconfig-${FONTCONFIG_VERSION}
tar xf fontconfig-${FONTCONFIG_VERSION}.tar.bz2
cd fontconfig-${FONTCONFIG_VERSION}
./configure ${HOST_ARG} \
  --enable-static --disable-shared --disable-dependency-tracking --prefix=${BUILD} \
  --with-expat=${BUILD}
make -j${JOBS}
make install
cd ${PACKAGES}
