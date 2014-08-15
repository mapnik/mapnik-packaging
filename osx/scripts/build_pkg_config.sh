#!/usr/bin/env bash
set -e -u
set -o pipefail
mkdir -p ${PACKAGES}
cd ${PACKAGES}

download pkg-config-${PKG_CONFIG_VERSION}.tar.gz

echoerr 'building pkg-config'

# patch glib.h
# change line 198 to:
#      ifndef G_INLINE_FUNC inline

if [ $BOOST_ARCH = "arm" ]; then
    OLD_PLATFORM=${MASON_PLATFORM}
    source ${ROOTDIR}/${HOST_PLATFORM}.sh
    NATIVE_PKG_CONFIG="${PACKAGES}/pkg-config-${PKG_CONFIG_VERSION}-${ARCH_NAME}/pkg-config"
    source ${ROOTDIR}/${OLD_PLATFORM}.sh
    if [ ! -f "${NATIVE_PKG_CONFIG}" ]; then
        echoerr 'native/host arch pkg-config missing, building now'
        source ${ROOTDIR}/${HOST_PLATFORM}.sh
        ${ROOTDIR}/scripts/build_pkg_config.sh
        source ${ROOTDIR}/${OLD_PLATFORM}.sh
        mkdir -p "${BUILD}/bin/"
        cp "${NATIVE_PKG_CONFIG}" ${BUILD}/bin/
    else
        echoerr "Found pkg-config for host arch (${NATIVE_PKG_CONFIG})"
        echoerr "Using pkg-config at ${BUILD}/bin/"
        mkdir -p "${BUILD}/bin/"
        cp "${NATIVE_PKG_CONFIG}" ${BUILD}/bin/
    fi
else
    # fixes duplicate symbols in ./.libs/libglib.a
    CFLAGS="$CFLAGS -std=gnu89"
    rm -rf pkg-config-${PKG_CONFIG_VERSION}-${ARCH_NAME}
    rm -rf pkg-config-${PKG_CONFIG_VERSION}
    tar xf pkg-config-${PKG_CONFIG_VERSION}.tar.gz
    mv pkg-config-${PKG_CONFIG_VERSION} pkg-config-${PKG_CONFIG_VERSION}-${ARCH_NAME}
    cd pkg-config-${PKG_CONFIG_VERSION}-${ARCH_NAME}
    ./configure ${HOST_ARG} \
        --disable-debug \
      --disable-dependency-tracking \
      --prefix=${BUILD} \
      --with-pc-path=${BUILD}/lib/pkgconfig
    $MAKE -j${JOBS}
    $MAKE install
fi

cd ${PACKAGES}
