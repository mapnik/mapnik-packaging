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

# generate root certs
# https://github.com/joyent/node/pull/6489
CA_BUNDLE="${BUILD}/etc/openssl/certs/ca-bundle.crt"
if [ ! -f ${CA_BUNDLE} ]; then
    rm -f ./ca-bundle.crt
    rm -f ./certdata.txt
    perl ${PACKAGES}/curl-${CURL_VERSION}/lib/mk-ca-bundle.pl
    if [[ ./ca-bundle.crt != "${CA_BUNDLE}" ]]; then
        cp ./ca-bundle.crt ${CA_BUNDLE}
    fi
    rm -f ./ca-bundle.crt
    rm -f ./certdata.txt
fi

# deps: http://curl.haxx.se/docs/libs.html
./configure --prefix=${BUILD} \
--enable-static \
--enable-shared \
--enable-manual \
--with-ssl=${BUILD} \
--with-zlib=${ZLIB_PATH} \
--without-ca-bundle \
--without-ca-path \
--without-darwinssl \
--without-gnutls \
--without-polarssl \
--without-cyassl \
--without-nss \
--without-axtls \
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

# test https with cert
echo ${BUILD}/bin/curl -I --cacert ${CA_BUNDLE} "https://www.mapbox.com/"
${BUILD}/bin/curl -I --cacert ${CA_BUNDLE} "https://www.mapbox.com/"

cd ${PACKAGES}
