#!/usr/bin/env bash
set -e -u
set -o pipefail
mkdir -p ${PACKAGES}
cd ${PACKAGES}

download openssl-${OPENSSL_VERSION}.tar.gz

echoerr '*building openssl'

OS_COMPILER=""
MAKEDEPEND="gccmakedep"

# NOTE: MAKEFLAGS=-r may come from gyp Makefiles
# and will break this build with:
# make[1]: *** No rule to make target `x86_64cpuid.o', needed by `../libcrypto.a'.  Stop.
# so check if it is set and warn
if [[ ${MAKEFLAGS:-false} != false ]]; then
    echoerr 'Warning MAKEFLAGS set, but we are disabling to prevent openssl pwnage'
fi
# now go ahead an unset MAKEFLAGS here to be safe
unset MAKEFLAGS

if [[ $UNAME == 'Darwin' ]]; then
    MAKEDEPEND="makedepend"
fi

if [[ ${MASON_PLATFORM} == 'MacOSX' ]]; then
    OS_COMPILER="darwin64-x86_64-cc enable-ec_nistp_64_gcc_128"
elif [[ ${MASON_PLATFORM} =~ 'iPhone' ]]; then
    if [[ ${ARCH_NAME} == 'arm64' ]]; then
        OS_COMPILER="BSD-generic64 enable-ec_nistp_64_gcc_128"
    else
        OS_COMPILER="BSD-generic32"
    fi
elif [[ ${MASON_PLATFORM} == 'Linux' ]]; then
    OS_COMPILER="linux-x86_64 enable-ec_nistp_64_gcc_128"
elif [[ ${MASON_PLATFORM} == 'Linaro-softfp' ]]; then
    OS_COMPILER="linux-armv4"
elif [[ ${MASON_PLATFORM} == 'Android' ]]; then
    OS_COMPILER="android-armv7"
else
    echoerr "unknown os/compiler version for your platform ${MASON_PLATFORM}"
    false
fi

if [[ ${OS_COMPILER} != "" ]]; then
    rm -rf openssl-${OPENSSL_VERSION}
    tar xf openssl-${OPENSSL_VERSION}.tar.gz
    cd openssl-${OPENSSL_VERSION}

    patch -N util/domd ${PATCHES}/openssl_makedepend.diff
    patch -N util/domd ${PATCHES}/openssl_nokrb.diff

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
    -no-krb5 \
    -DOPENSSL_NO_DEPRECATED \
    -DOPENSSL_NO_COMP \
    -DOPENSSL_NO_HEARTBEATS \
    -fPIC \
    --openssldir=${BUILD}/etc/openssl \
    ${OS_COMPILER}

    $MAKE depend MAKEDEPPROG=${MAKEDEPEND}

    $MAKE

    # https://github.com/openssl/openssl/issues/57
    $MAKE install_sw
fi

cd ${PACKAGES}
