#!/usr/bin/env bash
set -e -u
set -o pipefail
mkdir -p ${PACKAGES}
cd ${PACKAGES}

download openssl-${OPENSSL_VERSION}.tar.gz

echoerr '*building openssl'

OS_COMPILER=""
MAKEDEPEND=""

if [[ ${PLATFORM} == 'MacOSX' ]]; then
    OS_COMPILER="darwin64-x86_64-cc enable-ec_nistp_64_gcc_128"
    MAKEDEPEND="makedepend"
elif [[ ${PLATFORM} =~ 'iPhone' ]]; then
    if [[ ${ARCH_NAME} == 'arm64' ]]; then
        OS_COMPILER="BSD-generic64 enable-ec_nistp_64_gcc_128"
        MAKEDEPEND="makedepend"
    else
        OS_COMPILER="BSD-generic32"
        MAKEDEPEND="makedepend"
    fi
elif [[ ${PLATFORM} == 'Linux' ]]; then
    OS_COMPILER="linux-x86_64 enable-ec_nistp_64_gcc_128"
    MAKEDEPEND="gccmakedep"
elif [[ ${PLATFORM} == 'Linaro-softfp' ]]; then
    OS_COMPILER="linux-armv4"
    MAKEDEPEND="gccmakedep"
else
    echoerr "unknown os/compiler version for your platform ${PLATFORM}"
fi

if [[ ${OS_COMPILER} != "" ]]; then
    rm -rf openssl-${OPENSSL_VERSION}
    tar xf openssl-${OPENSSL_VERSION}.tar.gz
    cd openssl-${OPENSSL_VERSION}
    ./Configure \
    --prefix=${BUILD} \
    no-idea \
    no-mdc2 \
    no-rc5 \
    no-zlib \
    no-shared \
    enable-tlsext \
    no-ssl2 \
    --openssldir=${BUILD}/etc/openssl \
    ${OS_COMPILER}

    $MAKE depend MAKEDEPPROG=${MAKEDEPEND}

    # now re-configure to apply custom $CFLAGS
    CFLAGS="-DOPENSSL_NO_DEPRECATED -DOPENSSL_NO_COMP -DOPENSSL_NO_HEARTBEATS $CFLAGS"

    # we do this now to avoid breaking '$MAKE depend'
    ./Configure --prefix=${BUILD} \
    --openssldir=${BUILD}/etc/openssl \
    zlib-dynamic \
    no-shared \
    ${OS_COMPILER} \
    "$CFLAGS"

    $MAKE
    $MAKE install
fi

cd ${PACKAGES}
