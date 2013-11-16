set -e 

mkdir -p ${PACKAGES}
cd ${PACKAGES}

echo '*building node*'
rm -rf node-v${NODE_VERSION}
tar xf node-v${NODE_VERSION}.tar.gz
cd node-v${NODE_VERSION}
export mac_deployment_target=10.7 # todo this should overrides 10.5 in standalone.gypi
export OLD_LDFLAGS=${LDFLAGS}
export LDFLAGS="${STDLIB_LDFLAGS} ${LDFLAGS}"
./configure --prefix=${BUILD} \
 --shared-zlib \
 --shared-zlib-includes=${BUILD}/include \
 --shared-zlib-libpath=${BUILD}/lib
make -j${JOBS}
make install


cd ${ROOTDIR}
git clone git@github.com:mapnik/node-mapnik.git
cd ${ROOTDIR}/node-mapnik
mkdir -p node_modules
git clone git@github.com:mapbox/mapnik-vector-tile.git
cd mapnik-vector-tile
make && make test
install_name_tool -change /usr/local/lib/libmapnik.dylib `mapnik-config --prefix`/lib/libmapnik.dylib test/run-test 
make test
cd ../../

# avoid: dyld: Symbol not found: __ZN5boost6system16generic_categoryEv
# happens due to building libmapnik with --visibility=hidden
export LDFLAGS="-lboost_system ${LDFLAGS}"

# TODO: __ZN2v86String9NewSymbolEPKci results from building node with --visibility=hidden
# or __ZN2v811HandleScopeC1Ev
#export LDFLAGS="-L${PACKAGES}/node-v${NODE_VERSION}/out/Release/ -lv8_base -lv8_snapshot ${LDFLAGS}"

# Symbol not found: __ZN2v88internal8Snapshot13context_size_E

./configure --nodedir=${PACKAGES}/node-v${NODE_VERSION}
make
install_name_tool -change /usr/local/lib/libmapnik.dylib `mapnik-config --prefix`/lib/libmapnik.dylib lib/_mapnik.node

export LDFLAGS=${OLD_LDFLAGS}
