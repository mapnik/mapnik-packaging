#!/bin/bash
set -e -u
set -o pipefail
echo "...fixing install names of mapnik and dependencies"

mkdir -p "${MAPNIK_BIN_SOURCE}/share/mapnik/"
mkdir -p "${MAPNIK_BIN_SOURCE}/share/mapnik/icu"

DATA_FILE=$(find ${BUILD_ROOT}-*/share/icu/*/icudt*.dat -maxdepth 1 -name '*.dat' -print -quit)
if [ "${DATA_FILE}" ];then
    cp "${DATA_FILE}" "${MAPNIK_BIN_SOURCE}/share/mapnik/icu/"
fi
if [ -d ${BUILD}/share/proj ];then
  cp -r "${BUILD}/share/proj" "${MAPNIK_BIN_SOURCE}/share/mapnik/proj/"
fi
if [ -d ${BUILD}/share/gdal ];then
cp -r "${BUILD}/share/gdal" "${MAPNIK_BIN_SOURCE}/share/mapnik/gdal/"
fi

# py2cairo
for i in {"2.6","2.7","3.3"}
do
    if [ -d "${BUILD}/lib/python${i}/site-packages/cairo" ];then
        mkdir -p "${MAPNIK_BIN_SOURCE}/lib/python${i}/site-packages/"
        cp -R "${BUILD}/lib/python${i}/site-packages/cairo" "${MAPNIK_BIN_SOURCE}/lib/python${i}/site-packages/"
    fi
done

# fixup plugins
if [ $UNAME = 'Linux' ]; then
  echo todo
fi

if [ $UNAME = 'Darwin' ]; then

    for i in $(ls ${MAPNIK_BIN_SOURCE}/lib/mapnik/input/*input)
    do
        install_name_tool -change `otool -L "$i" | grep libmapnik | awk '{print $1}'` @loader_path/../../libmapnik.dylib ${i}
    done

    # fixup c++ programs
    if [ -d "${MAPNIK_BIN_SOURCE}/bin/pgsql2sqlite" ]; then
        install_name_tool -change `otool -L "$i" | grep libmapnik | awk '{print $1}'` @loader_path/../lib/libmapnik.dylib ${MAPNIK_BIN_SOURCE}/bin/pgsql2sqlite
    fi
    if [ -d "${MAPNIK_BIN_SOURCE}/bin/svg2png" ]; then
        install_name_tool -change `otool -L "$i" | grep libmapnik | awk '{print $1}'` @loader_path/../lib/libmapnik.dylib ${MAPNIK_BIN_SOURCE}/bin/pgsql2sqlite
    fi
    for i in $(ls ${MAPNIK_SOURCE}/tests/cpp_tests/*-bin);
        do install_name_tool -change `otool -L "$i" | grep libmapnik | awk '{print $1}'` ${MAPNIK_BIN_SOURCE}/lib/libmapnik.dylib $i;
    done

    # fixup python

    for i in {"2.6","2.7","3.3"}
    do
        this_dir="${MAPNIK_BIN_SOURCE}/lib/python${i}/site-packages/mapnik"
        if [ -d  $this_dir ];then
            install_name_tool -change `otool -L "$this_dir/_mapnik.so" | grep libmapnik | awk '{print $1}'` @loader_path/../../../libmapnik.dylib $this_dir/_mapnik.so
        fi
    done

    # cleanups
    find ${MAPNIK_BIN_SOURCE} -name ".DS_Store" -exec rm -f {} \;

fi
