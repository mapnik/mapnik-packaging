
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
    OLD_LD_PRELOAD_VALUE="${LD_PRELOAD}"
    export LD_PRELOAD="$(pwd)/plugins/input/libgdal.so.1"
fi

$MAKE test-local || true

if [[ ${OFFICIAL_RELEASE} == true ]]; then
    for i in {"2.7","2.6",}
    do
      if [ -d "${MAPNIK_BIN_SOURCE}/lib/python${i}/site-packages/mapnik" ]; then
          echo testing against python $i
          export PYTHONPATH=${MAPNIK_BIN_SOURCE}/lib/python${i}/site-packages/
          export PATH=${MAPNIK_BIN_SOURCE}/bin:$PATH
          # TODO - allow setting python version in $MAKE wrapper
          #$MAKE test
          python${i} tests/visual_tests/test.py -q
          python${i} tests/run_tests.py -q
      else
          echo skipping test against python $i
      fi
    done
fi

if [[ ${USE_LTO} == true ]]; then
    export LD_PRELOAD="${OLD_LD_PRELOAD_VALUE}"
fi
