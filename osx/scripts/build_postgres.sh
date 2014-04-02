#!/bin/bash
set -e -u
set -o pipefail
mkdir -p ${PACKAGES}
cd ${PACKAGES}

download postgresql-${POSTGRES_VERSION}.tar.gz

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
tar xf postgresql-${POSTGRES_VERSION}.tar.gz
cd postgresql-${POSTGRES_VERSION}
if [[ ${PLATFORM} == 'Linux' ]]; then
    # https://github.com/mapnik/mapnik-packaging/issues/130
    patch -N src/include/pg_config_manual.h ${PATCHES}/pg_config_manual.diff || true
fi

./configure ${HOST_ARG} \
--prefix=${BUILD} \
--without-bonjour --without-openssl --without-pam --without-krb5 --without-gssapi --enable-thread-safety \
--without-libxml --without-readline --without-ldap
# LD=${CC}
# TODO - linking problems for unknown reasons...
set +e
make -j${JOBS} -i -k
make install -i -k
set -e
cd ${PACKAGES}

check_and_clear_libs
