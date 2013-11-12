set -e

mkdir -p ${PACKAGES}
cd ${PACKAGES}

echo '*building node*'
rm -rf node-v${NODE_VERSION}
tar xf node-v${NODE_VERSION}.tar.gz
cd node-v${NODE_VERSION}
cd tools/gyp
# https://github.com/joyent/node/issues/3681
curl -o issue_292.diff https://codereview.chromium.org/download/issue14887003_1_2.diff
patch pylib/gyp/xcode_emulation.py issue_292.diff
cd ../../
export mac_deployment_target=10.7 # todo this should override 10.5 in standalone.gypi
export OLD_LDFLAGS=${LDFLAGS}
export OLD_CXXFLAGS=${CXXFLAGS}
export CXXFLAGS="-mmacosx-version-min=10.7 ${CXXFLAGS}"
export LDFLAGS="-mmacosx-version-min=10.7 ${STDLIB_LDFLAGS} ${LDFLAGS}"
./configure --prefix=${BUILD} \
 --shared-zlib \
 --shared-zlib-includes=${BUILD}/include \
 --shared-zlib-libpath=${BUILD}/lib
make -j${JOBS}
make install
export LDFLAGS=${OLD_LDFLAGS}
export CXXFLAGS=${OLD_CXXFLAGS}
