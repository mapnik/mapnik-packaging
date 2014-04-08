#!/bin/bash
set -e -u
set -o pipefail
mkdir -p "${BUILD_UNIVERSAL}"

function add_library() {
    cp -r "${BUILD_ROOT}-$1/" "${BUILD_ROOT}-universal"
    BUILD_ROOT_ESCAPED=$(echo "${BUILD_ROOT}" | sed -e 's/[]\/()$*.^|[]/\\&/g')
    find ${BUILD_ROOT}-universal/ \( -name "*.pc" -or -name "*.la" -or -name "*-config" \) \
        -exec sed -i '' "s/${BUILD_ROOT_ESCAPED}-$1/${BUILD_ROOT_ESCAPED}-universal/g" {} \;
    FROM_LIBS="$FROM_LIBS ${BUILD_ROOT}-$1/lib/${libname}"
}

if [[ $UNAME == 'Darwin' ]]; then
    echo '*making universal libs*'
    ARCHS="x86_64 arm64 armv7s armv7 i386"
    LIBS=$(find ${ROOTDIR}/out/*/lib -maxdepth 1 -name '*.a' -exec basename '{}' \; | sort | uniq)
    for libname in ${LIBS}; do
        echo '*making universal '$libname'*'
        FROM_LIBS=""
        for arch in ${ARCHS}; do
            if [ -f "${BUILD_ROOT}-${arch}/lib/${libname}" ]; then
                add_library $arch
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
            "${BUILD_ROOT}-x86_64-mapnik/${MAPNIK_INSTALL}/lib/libmapnik.a" \
            "${BUILD_ROOT}-arm64-mapnik/${MAPNIK_INSTALL}/lib/libmapnik.a" \
            "${BUILD_ROOT}-armv7s-mapnik/${MAPNIK_INSTALL}/lib/libmapnik.a" \
            "${BUILD_ROOT}-armv7-mapnik/${MAPNIK_INSTALL}/lib/libmapnik.a" \
            "${BUILD_ROOT}-i386-mapnik/${MAPNIK_INSTALL}/lib/libmapnik.a"
    fi

fi

