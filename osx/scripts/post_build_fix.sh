#!/usr/bin/env bash
set -e -u
set -o pipefail
echo "...fixing install names of mapnik and dependencies"

mkdir -p "${MAPNIK_BIN_SOURCE}/share/mapnik/"

mkdir -p "${MAPNIK_BIN_SOURCE}/share/mapnik/icu"
DATA_FILE=$(find ${BUILD}/share/icu/*/icudt*.dat -maxdepth 1 -name '*.dat' -print -quit)
if [ "${DATA_FILE}" ];then
    cp "${DATA_FILE}" "${MAPNIK_BIN_SOURCE}/share/mapnik/icu/"
fi
if [ -d ${BUILD}/share/proj ];then
  cp -r "${BUILD}/share/proj" "${MAPNIK_BIN_SOURCE}/share/mapnik/"
fi
if [ -d ${BUILD}/share/gdal ];then
  cp -r "${BUILD}/share/gdal" "${MAPNIK_BIN_SOURCE}/share/mapnik/"
  rm -f "${MAPNIK_BIN_SOURCE}/share/mapnik/gdal/*svg"
  rm -f "${MAPNIK_BIN_SOURCE}/share/mapnik/gdal/*png"
  rm -f "${MAPNIK_BIN_SOURCE}/share/mapnik/gdal/*ini"
fi


# fixup plugins
if [ $UNAME = 'Linux' ]; then
  echo todo
fi

if [ $UNAME = 'Linux' ]; then
    function fix_gdal_shared() {
        if [[ -f "$1" ]] && [[ -f "${BUILD}/lib/libgdal.so" ]]; then
            cp ${BUILD}/lib/libgdal.so.20 "$(dirname "$1")/"
            #for i in $(find ${BUILD}/lib/libgdal* -maxdepth 1 -name '*so*' -print); do
            #    cp ${i} "$(dirname "$1")/"
            #done;
        fi
    }

    # move shared gdal into place
    fix_gdal_shared "${MAPNIK_BIN_SOURCE}/lib/mapnik/input/gdal.input"
    fix_gdal_shared "${MAPNIK_BIN_SOURCE}/lib/mapnik/input/ogr.input"
    fix_gdal_shared "${MAPNIK_SOURCE}/plugins/input/gdal.input"
    fix_gdal_shared "${MAPNIK_SOURCE}/plugins/input/ogr.input"

elif [ $UNAME = 'Darwin' ]; then

    function fix_gdal_shared() {
        if [[ -f "$1" ]]; then
            LIBGDAL_PLACED="$(dirname "$1")/libgdal_mapnik.dylib"
            # get path to exact libgdal linked to from mapnik plugin
            LIBGDAL_PATH=$(otool -L "$1" | grep libgdal. | awk '{print $1}')
            cp ${BUILD}/lib/libgdal.dylib ${LIBGDAL_PLACED}
            install_name_tool -id @loader_path/libgdal_mapnik.dylib ${LIBGDAL_PLACED}
            # now rebuild the linkage given the new name
            install_name_tool -change ${LIBGDAL_PATH} \
              @loader_path/libgdal_mapnik.dylib \
              "$1"
        fi
    }

    for i in $(ls ${MAPNIK_BIN_SOURCE}/lib/mapnik/input/*input)
    do
        install_name_tool -change $(otool -L "$i" | grep libmapnik | awk '{print $1}') @loader_path/../../libmapnik.dylib ${i}
    done

    fix_gdal_shared "${MAPNIK_BIN_SOURCE}/lib/mapnik/input/gdal.input"
    fix_gdal_shared "${MAPNIK_BIN_SOURCE}/lib/mapnik/input/ogr.input"
    #fix_gdal_shared "${MAPNIK_SOURCE}/plugins/input/gdal.input"
    #fix_gdal_shared "${MAPNIK_SOURCE}/plugins/input/ogr.input"

    # fixup c++ programs
    if [ -d "${MAPNIK_BIN_SOURCE}/bin/pgsql2sqlite" ]; then
        install_name_tool -change $(otool -L "$i" | grep libmapnik | awk '{print $1}') @loader_path/../lib/libmapnik.dylib ${MAPNIK_BIN_SOURCE}/bin/pgsql2sqlite
    fi
    if [ -d "${MAPNIK_BIN_SOURCE}/bin/svg2png" ]; then
        install_name_tool -change $(otool -L "$i" | grep libmapnik | awk '{print $1}') @loader_path/../lib/libmapnik.dylib ${MAPNIK_BIN_SOURCE}/bin/pgsql2sqlite
    fi
    # note: requires -Wl,-headerpad_max_install_names
    # and now obsolete by `make test-local`
    #for i in $(ls ${MAPNIK_SOURCE}/tests/cpp_tests/*-bin);
    #    do install_name_tool -change $(otool -L "$i" | grep libmapnik | awk '{print $1}') ${MAPNIK_BIN_SOURCE}/lib/libmapnik.dylib $i;
    #done

    # cleanups
    find ${MAPNIK_BIN_SOURCE} -name ".DS_Store" -exec rm -f {} \;

fi
