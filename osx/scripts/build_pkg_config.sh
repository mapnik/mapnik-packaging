#!/bin/bash
set -e -u

mkdir -p ${PACKAGES}
cd ${PACKAGES}

download pkg-config-${PKG_CONFIG_VERSION}.tar.gz

echoerr 'building pkg-config'
rm -rf pkg-config-${PKG_CONFIG_VERSION}
tar xf pkg-config-${PKG_CONFIG_VERSION}.tar.gz
cd pkg-config-${PKG_CONFIG_VERSION}
# patch glib.h
# change line 198 to:
#      ifndef G_INLINE_FUNC inline
export OLD_CFLAGS=$CFLAGS
export CFLAGS="$CFLAGS -std=gnu89"

./configure --disable-debug \
  --disable-dependency-tracking \
  --prefix=${BUILD} \
  --with-pc-path=${BUILD}/lib/pkgconfig
  
make -j${JOBS}
make install
export CFLAGS=$OLD_CFLAGS
cd ${PACKAGES}
