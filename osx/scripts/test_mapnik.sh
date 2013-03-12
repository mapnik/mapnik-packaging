cd ${MAPNIK_SOURCE}
echo '*** testing locally'
make test-local

echo '*** testing install'
export DYLD_LIBRARY_PATH=`pwd`/src

for i in {"2.6","2.7"}
do
  export PYTHONPATH=${MAPNIK_INSTALL}/lib/python${i}/site-packages/
  export PATH=${MAPNIK_INSTALL}/bin:$PATH
  make test
done
