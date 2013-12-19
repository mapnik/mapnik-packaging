#!/bin/bash
set -e -u -x

echo '*** testing install'
cd ${MAPNIK_SOURCE}
# setup 'share' symlink
SHARE_DIR="`pwd`/../../share"
mkdir -p $SHARE_DIR
TEMP_SYMLINK="$SHARE_DIR/mapnik"
if [ ! -d "${MAPNIK_BIN_SOURCE}/share/mapnik" ]; then
  ${ROOTDIR}/scripts/post_build_fix.sh
fi
ln -s ${MAPNIK_BIN_SOURCE}/share/mapnik ${TEMP_SYMLINK}

export DYLD_LIBRARY_PATH=`pwd`/src
export MAPNIK_FONT_DIRECTORY=`pwd`/fonts/dejavu-fonts-ttf-2.33/ttf/
export MAPNIK_INPUT_PLUGINS_DIRECTORY=`pwd`/plugins/input/

for i in {"2.7","2.6",}
do
  if [ -d "${MAPNIK_BIN_SOURCE}/lib/python${i}/site-packages/mapnik" ]; then
      echo testing against python $i
      export PYTHONPATH=${MAPNIK_BIN_SOURCE}/lib/python${i}/site-packages/
      export PATH=${MAPNIK_BIN_SOURCE}/bin:$PATH
      # TODO - allow setting python version in make wrapper
      #make test
      python${i} tests/visual_tests/test.py -q
      python${i} tests/run_tests.py -q
  else
      echo skipping test against python $i
  fi
done

rm ${TEMP_SYMLINK}
