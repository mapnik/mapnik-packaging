#!/usr/bin/env bash
set -e -u
set -o pipefail
mkdir -p ${PACKAGES}
cd ${PACKAGES}

echoerr 'building lua'

download lua-${LUA_VERSION}.tar.gz

rm -rf lua-${LUA_VERSION}
tar xf lua-${LUA_VERSION}.tar.gz
cd lua-${LUA_VERSION}
$MAKE generic CC=$CC CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" INSTALL_TOP=${BUILD} install

cd ${PACKAGES}
