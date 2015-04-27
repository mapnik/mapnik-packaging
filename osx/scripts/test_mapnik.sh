
#!/usr/bin/env bash
set -e -u
set -o pipefail
echo '*** testing install'
if [ ! -d "${MAPNIK_BIN_SOURCE}/share/mapnik" ]; then
  ${ROOTDIR}/scripts/post_build_fix.sh
fi

echoerr 'testing build in place'
export ICU_DATA="${MAPNIK_BIN_SOURCE}/share/mapnik/icu"
export GDAL_DATA="${MAPNIK_BIN_SOURCE}/share/mapnik/gdal"
export PROJ_LIB="${MAPNIK_BIN_SOURCE}/share/mapnik/proj"
cd ${MAPNIK_SOURCE}

if [[ ${USE_LTO} == true ]]; then
    if [[ "${LDPRELOAD:-false}" != false ]]; then
        OLD_LD_PRELOAD_VALUE="${LD_PRELOAD}"
    fi
    export LD_PRELOAD="$(pwd)/plugins/input/libgdal.so.1"
fi

$MAKE test || true

if [[ ${USE_LTO} == true ]]; then
    if [[ "${OLD_LD_PRELOAD_VALUE:-false}" != false ]]; then
        export LD_PRELOAD="${OLD_LD_PRELOAD_VALUE}"
    fi
fi

set +e +u

