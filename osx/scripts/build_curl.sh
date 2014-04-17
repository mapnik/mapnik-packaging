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

# download root certs. this is totally unsafe, we're playing with fire here.
mkdir -p "${BUILD}/etc/openssl/certs"
CA_BUNDLE="${BUILD}/etc/openssl/certs/ca-bundle.crt"
if [ ! -f ${CA_BUNDLE} ]; then
    ${BUILD}/bin/curl --silent http://curl.haxx.se/ca/cacert.pem -o ${BUILD}/etc/openssl/certs/ca-bundle.crt
fi

# test https with cert
echo ${BUILD}/bin/curl -I --cacert ${CA_BUNDLE} "https://www.mapbox.com/"
${BUILD}/bin/curl -I --cacert ${CA_BUNDLE} "https://www.mapbox.com/"
# remove curl command line now since the lack of default-known certs
# will break other curl commands that the build system depends on
# so we fall back to system curl command
rm -f ${BUILD}/bin/curl
cd ${PACKAGES}
