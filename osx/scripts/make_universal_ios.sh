#!/bin/bash
set -e -u
set -o pipefail
mkdir -p "${BUILD_UNIVERSAL}"

if [[ $UNAME == 'Darwin' ]]; then
    echo '*making universal libs*'
    ARCHS="arm64 armv7s armv7 i386"
    LIBS=$(find ${ROOTDIR}/out/*/lib -maxdepth 1 -name '*.a' -exec basename '{}' \; | sort | uniq)

    for arch in ${ARCHS}; do
        if [ -d "${BUILD_ROOT}-${arch}" ]; then
            echo '*merging '${BUILD_ROOT}'-'${arch}'*'
            ditto "${BUILD_ROOT}-${arch}/" "${BUILD_ROOT}-universal"
            build_root_escaped=$(echo "${BUILD_ROOT}" | sed -e 's/[]\/()$*.^|[]/\\&/g')
            find ${BUILD_ROOT}-universal/ \( -name "*.pc" -or -name "*.la" -or -name "*-config" \) \
                -exec sed -i '' "s/${build_root_escaped}-${arch}/${build_root_escaped}-universal/g" {} \;
        fi
    done;

    for libname in ${LIBS}; do
        echo '*making universal '$libname'*'
        FROM_LIBS=""
        for arch in ${ARCHS}; do
            if [ -f "${BUILD_ROOT}-${arch}/lib/${libname}" ]; then
                FROM_LIBS="$FROM_LIBS ${BUILD_ROOT}-${arch}/lib/${libname}"
            fi
        done;

        lipo -create -output \
            "${BUILD_UNIVERSAL}/lib/${libname}" \
            $FROM_LIBS
        lipo -info "${BUILD_UNIVERSAL}/lib/${libname}"
    done;

    if [ -f ${MAPNIK_BIN_SOURCE}/lib/libmapnik.a ]; then
        echo '*making universal mapnik*'
        lipo -create -output \
            "${BUILD_UNIVERSAL}/libmapnik.a" \
            "${BUILD_ROOT}-arm64-mapnik/${MAPNIK_INSTALL}/lib/libmapnik.a" \
            "${BUILD_ROOT}-armv7s-mapnik/${MAPNIK_INSTALL}/lib/libmapnik.a" \
            "${BUILD_ROOT}-armv7-mapnik/${MAPNIK_INSTALL}/lib/libmapnik.a" \
            "${BUILD_ROOT}-i386-mapnik/${MAPNIK_INSTALL}/lib/libmapnik.a"
    fi

fi

