#!/usr/bin/env bash
set -e -u
set -o pipefail
mkdir -p ${PACKAGES}
cd ${PACKAGES}

download postgresql-${POSTGRES_VERSION}.tar.bz2

# postgres
echoerr 'building postgres for libpq client library'

# 64 bit build
echoerr 'building postgres 64 bit'
cd ${PACKAGES}
rm -rf postgresql-${POSTGRES_VERSION}
tar xf postgresql-${POSTGRES_VERSION}.tar.bz2
cd postgresql-${POSTGRES_VERSION}
if [[ ${MASON_PLATFORM} == 'Linux' ]]; then
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

$MAKE -j${JOBS} -C src/bin/pg_config install
$MAKE -j${JOBS} -C src/interfaces/libpq/ install
cp src/include/postgres_ext.h ${BUILD}/include/
cp src/include/pg_config_ext.h ${BUILD}/include/
cd ${PACKAGES}

rm -f ${BUILD}/lib/libpq{*.so*,*.dylib}

check_and_clear_libs
