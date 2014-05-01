#!/usr/bin/env bash
set -e -u
set -o pipefail
mkdir -p ${PACKAGES}
cd ${PACKAGES}

download postgresql-${POSTGRES_VERSION}.tar.gz

# postgres
echoerr 'building postgres for libpq client library'

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
--enable-thread-safety \
--enable-largefile \
--without-bonjour \
--without-openssl \
--without-pam \
--without-krb5 \
--without-gssapi \
--without-ossp-uuid \
--without-readline \
--without-ldap \
--without-zlib \
--without-libxml \
--without-libxslt \
--without-selinux \
--without-python \
--without-perl \
--without-tcl \
--disable-rpath \
--disable-debug \
--disable-profiling \
--disable-coverage \
--disable-dtrace \
--disable-depend \
--disable-cassert

# LD=${CC}
# TODO - linking problems for unknown reasons...
set +e
$MAKE -j${JOBS} -i -k
$MAKE install -i -k
set -e
cd ${PACKAGES}

check_and_clear_libs
