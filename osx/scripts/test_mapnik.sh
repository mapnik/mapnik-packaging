# setup 'share' symlink
TEMP_SYMLINK="`pwd`/../share"
ln -s ${MAPNIK_BIN_SOURCE}/share ${TEMP_SYMLINK}

cd ${MAPNIK_SOURCE}
echo '*** testing locally'
make test-local

echo '*** testing install'
export DYLD_LIBRARY_PATH=`pwd`/src
export MAPNIK_FONT_DIRECTORY=`pwd`/fonts/dejavu-fonts-ttf-2.33/ttf/
export MAPNIK_INPUT_PLUGINS_DIRECTORY=`pwd`/plugins/input/

for i in {"2.6","2.7"}
do
  export PYTHONPATH=${MAPNIK_BIN_SOURCE}/lib/python${i}/site-packages/
  export PATH=${MAPNIK_BIN_SOURCE}/bin:$PATH
  # TODO - allow setting python version in make wrapper
  #make test
  python${i} tests/visual_tests/test.py -q
  python${i} tests/run_tests.py -q
done

rm ${TEMP_SYMLINK}
