#!/bin/bash
set -e -u
set -o pipefail
mkdir -p ${PACKAGES}
cd ${PACKAGES}


download curl-${CURL_VERSION}.tar.bz2
echo 'building curl'
rm -rf curl-${CURL_VERSION}
tar xf curl-${CURL_VERSION}.tar.bz2
cd curl-${CURL_VERSION}
./configure --prefix=${BUILD} \
--enable-static \
--enable-shared \
--enable-manual \
--with-zlib=${ZLIB_PATH} \
--without-darwinssl \
--without-gnutls \
--without-polarssl \
--without-cyassl \
--without-nss \
--without-axtls \
--without-ca-bundle \
--without-ca-path \
--without-libmetalink \
--without-libssh2 \
--without-librtmp \
--without-winidn \
--without-libidn \
--without-nghttp2 \
--disable-ldap \
--disable-ldaps \
--disable-ldap \
--disable-ftp \
--disable-file \
--disable-rtsp \
--disable-proxy \
--disable-dict \
--disable-telnet \
--disable-tftp \
--disable-pop3 \
--disable-imap \
--disable-smtp \
--disable-gopher \
--disable-libcurl-option \
--disable-sspi \
--disable-crypto-auth \
--disable-ntlm-wb \
--disable-tls-srp \
--disable-cookies
make -j$JOBS
make install
cd ${PACKAGES}
