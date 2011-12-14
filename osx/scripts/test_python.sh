set -e
cd ${MAPNIK_SOURCE}

for i in {"2.6","2.7"}
do
    export PYTHONPATH=${MAPNIK_INSTALL}/lib/python${i}/site-packages/
    make test
done
