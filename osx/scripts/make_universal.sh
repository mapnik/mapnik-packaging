#!/bin/bash
set -e -u
set -o pipefail
mkdir -p "${BUILD_UNIVERSAL}"

if [[ $UNAME == 'Darwin' ]]; then
    echo '*making universal libs*'
    for i in $(find ${BUILD}/lib/ -maxdepth 1 -name '*.a' -print); do
        echo '*making universal '$i'*'
        FROM_LIBS=""
        libname=$(basename $i)
        if [ -f "${BUILD_ROOT}-x86_64/lib/${libname}" ]; then
            FROM_LIBS="$FROM_LIBS ${BUILD_ROOT}-x86_64/lib/${libname}"
        fi
        if [ -f "${BUILD_ROOT}-arm64/lib/${libname}" ]; then
            FROM_LIBS="$FROM_LIBS ${BUILD_ROOT}-arm64/lib/${libname}"
        fi
        if [ -f "${BUILD_ROOT}-armv7s/lib/${libname}" ]; then
            FROM_LIBS="$FROM_LIBS ${BUILD_ROOT}-armv7s/lib/${libname}"
        fi
        if [ -f "${BUILD_ROOT}-armv7/lib/${libname}" ]; then
            FROM_LIBS="$FROM_LIBS ${BUILD_ROOT}-armv7/lib/${libname}"
        fi
        if [ -f "${BUILD_ROOT}-i386/lib/${libname}" ]; then
            FROM_LIBS="$FROM_LIBS ${BUILD_ROOT}-i386/lib/${libname}"
        fi
        lipo -create -output \
            "${BUILD_UNIVERSAL}/${libname}" \
            $FROM_LIBS
        lipo -info "${BUILD_UNIVERSAL}/${libname}"
    done;

    if [ -f ${MAPNIK_BIN_SOURCE}/lib/libmapnik.a ]; then
        echo '*making universal mapnik*'
        lipo -create -output \
            "${BUILD_UNIVERSAL}/libmapnik.a" \
            "${BUILD_ROOT}-x86_64-mapnik/${MAPNIK_INSTALL}/lib/libmapnik.a" \
            "${BUILD_ROOT}-arm64-mapnik/${MAPNIK_INSTALL}/lib/libmapnik.a" \
            "${BUILD_ROOT}-armv7s-mapnik/${MAPNIK_INSTALL}/lib/libmapnik.a" \
            "${BUILD_ROOT}-armv7-mapnik/${MAPNIK_INSTALL}/lib/libmapnik.a" \
            "${BUILD_ROOT}-i386-mapnik/${MAPNIK_INSTALL}/lib/libmapnik.a"
    fi

fi

