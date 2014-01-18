#!/bin/bash
set -e -u

mkdir -p ${PACKAGES}
cd ${PACKAGES}

echoerr 'building lua'

#download lua-${LUA_VERSION}.tar.gz

rm -rf lua-5.1.5
tar xf lua-5.1.5.tar.gz
cd lua-5.1.5
make generic CC=$CC CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" INSTALL_TOP=${BUILD} install

cd ${PACKAGES}
