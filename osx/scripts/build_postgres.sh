#!/bin/bash
set -e -u -x

mkdir -p ${PACKAGES}
cd ${PACKAGES}

download postgresql-${POSTGRES_VERSION}.tar.bz2

# postgres
echoerr 'building postgres for libpq client library'

: '
postgres/INSTALL has:
       Client-only installation: If you want to install only the client
       applications and interface libraries, then you can use these
       commands:
gmake -C src/bin install
gmake -C src/include install
gmake -C src/interfaces install
gmake -C doc install
'

# 64 bit build
echoerr 'building postgres 64 bit'
cd ${PACKAGES}
rm -rf postgresql-${POSTGRES_VERSION}
tar xf postgresql-${POSTGRES_VERSION}.tar.bz2
cd postgresql-${POSTGRES_VERSION}
./configure --prefix=${BUILD} \
--with-openssl --with-pam --with-krb5 --with-gssapi --with-ldap --enable-thread-safety \
--with-bonjour --without-libxml --without-readline
# LD=${CC}
# TODO - linking problems for unknown reasons...
set +e
make -j${JOBS} -i -k
make install -i -k
set -e
cd ${PACKAGES}

check_and_clear_libs
