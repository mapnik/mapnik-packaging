#!/usr/bin/env bash
set -e -u 

mkdir -p ${PACKAGES}
cd ${PACKAGES}

download sqlite-autoconf-${SQLITE_VERSION}.tar.gz

echoerr 'building sqlite'
rm -rf sqlite-autoconf-${SQLITE_VERSION}
tar xf sqlite-autoconf-${SQLITE_VERSION}.tar.gz
cd sqlite-autoconf-${SQLITE_VERSION}
CFLAGS="-DSQLITE_ENABLE_RTREE=1 $CFLAGS"
./configure ${HOST_ARG} \
--prefix=${BUILD} \
--enable-readline=no \
--enable-editline=no \
--enable-dynamic-extensions=no \
--enable-static \
--disable-shared \
--disable-dependency-tracking
$MAKE -j${JOBS}
$MAKE install
cd ${PACKAGES}
