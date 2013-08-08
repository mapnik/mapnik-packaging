set -e 

mkdir -p ${PACKAGES}
cd ${PACKAGES}

echo '*building node*'
rm -rf node-v${NODE_VERSION}
tar xf node-v${NODE_VERSION}.tar.gz
cd node-v${NODE_VERSION}
export mac_deployment_target=10.7 # todo this should overrided 10.5 in standalone.gypi
export OLD_LDFLAGS=${LDFLAGS}
export LDFLAGS="${STDLIB_LDFLAGS} ${LDFLAGS}"
./configure --prefix=${BUILD} \
 --shared-zlib \
 --shared-zlib-includes=${BUILD}/include \
 --shared-zlib-libpath=${BUILD}/lib
make -j${JOBS}
make install
export LDFLAGS=${OLD_LDFLAGS}
