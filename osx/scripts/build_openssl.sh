#!/usr/bin/env bash
set -e -u
set -o pipefail
mkdir -p ${PACKAGES}
cd ${PACKAGES}

download openssl-${OPENSSL_VERSION}.tar.gz

echoerr '*building openssl'

OS_COMPILER=""
MAKEDEPEND="gccmakedep"

if [[ $UNAME == 'Darwin' ]]; then
    MAKEDEPEND="makedepend"
fi

if [[ ${PLATFORM} == 'MacOSX' ]]; then
    OS_COMPILER="darwin64-x86_64-cc enable-ec_nistp_64_gcc_128"
elif [[ ${PLATFORM} =~ 'iPhone' ]]; then
    if [[ ${ARCH_NAME} == 'arm64' ]]; then
        OS_COMPILER="BSD-generic64 enable-ec_nistp_64_gcc_128"
    else
        OS_COMPILER="BSD-generic32"
    fi
elif [[ ${PLATFORM} == 'Linux' ]]; then
    OS_COMPILER="linux-x86_64 enable-ec_nistp_64_gcc_128"
elif [[ ${PLATFORM} == 'Linaro-softfp' ]]; then
    OS_COMPILER="linux-armv4"
elif [[ ${PLATFORM} == 'Android' ]]; then
    OS_COMPILER="android-armv7"
else
    echoerr "unknown os/compiler version for your platform ${PLATFORM}"
fi

if [[ ${OS_COMPILER} != "" ]]; then
    rm -rf openssl-${OPENSSL_VERSION}
    tar xf openssl-${OPENSSL_VERSION}.tar.gz
    cd openssl-${OPENSSL_VERSION}

    patch -N util/domd ${PATCHES}/openssl_makedepend.diff

    ./Configure \
    --prefix=${BUILD} \
    enable-tlsext \
    -no-dso \
    -no-hw \
    -no-comp \
    -no-idea \
    -no-mdc2 \
    -no-rc5 \
    -no-zlib \
    -no-shared \
    -no-ssl2 \
    -no-ssl3 \
    --openssldir=${BUILD}/etc/openssl \
    ${OS_COMPILER}

    $MAKE depend MAKEDEPPROG=${MAKEDEPEND}

    # now re-configure to apply custom $CFLAGS
    CFLAGS="-DOPENSSL_NO_DEPRECATED -DOPENSSL_NO_COMP -DOPENSSL_NO_HEARTBEATS -static $CFLAGS"

    # we do this now to avoid breaking '$MAKE depend'
    ./Configure --prefix=${BUILD} \
    --openssldir=${BUILD}/etc/openssl \
    zlib-dynamic \
    no-shared \
    ${OS_COMPILER} \
    "$CFLAGS"

    $MAKE
    # https://github.com/openssl/openssl/issues/57
    $MAKE install_sw
fi

cd ${PACKAGES}
