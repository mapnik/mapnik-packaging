#!/bin/bash
set -e -u
set -o pipefail
mkdir -p ${PACKAGES}
cd ${PACKAGES}

download openssl-${OPENSSL_VERSION}.tar.gz

echoerr '*building openssl'
rm -rf openssl-${OPENSSL_VERSION}
tar xf openssl-${OPENSSL_VERSION}.tar.gz
cd openssl-${OPENSSL_VERSION}
./Configure --prefix=${BUILD} \
--openssldir=${BUILD}/etc/openssl \
zlib-dynamic \
no-shared \
darwin64-x86_64-cc \
enable-ec_nistp_64_gcc_128
make depend
# now re-configure to put $CFLAGS
# we do this now to avoid breaking 'make depend'
./Configure --prefix=${BUILD} \
--openssldir=${BUILD}/etc/openssl \
zlib-dynamic \
no-shared \
darwin64-x86_64-cc \
enable-ec_nistp_64_gcc_128 \
"$CFLAGS"
make
#make -j${JOBS}
#make install
cd ${PACKAGES}
