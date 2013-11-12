set -e

mkdir -p ${PACKAGES}
cd ${PACKAGES}

echo '*building sparsehash C++*'
rm -rf sparsehash-${SPARSEHASH_VERSION}-${ARCH_NAME}
tar xf sparsehash-${SPARSEHASH_VERSION}.tar.gz
mv sparsehash-${SPARSEHASH_VERSION} sparsehash-${SPARSEHASH_VERSION}-${ARCH_NAME}
cd sparsehash-${SPARSEHASH_VERSION}-${ARCH_NAME}
if [ $BOOST_ARCH = "arm" ]; then
    if [ -f "$(pwd)/../protobuf-${PROTOBUF_VERSION}-i386/src/protoc" ]; then
        NATIVE_PROTOC="$(pwd)/../protobuf-${PROTOBUF_VERSION}-i386/src/protoc"
    elif [ -f "$(pwd)/../protobuf-${PROTOBUF_VERSION}-x86-64/src/protoc" ]; then
        NATIVE_PROTOC="$(pwd)/../protobuf-${PROTOBUF_VERSION}-x86-64/src/protoc"
    else
        echo 'could not find pre-built protobuf/protoc from a native/host arch!'
    fi
    export CROSS_FLAGS="--with-protoc=${NATIVE_PROTOC}"
else
    export CROSS_FLAGS=""
fi
export OLD_LDFLAGS=${LDFLAGS}
export LDFLAGS="${STDLIB_LDFLAGS} ${LDFLAGS}"
./configure --prefix=${BUILD} ${HOST_ARG} ${CROSS_FLAGS} \
--enable-static --enable-shared \
--disable-debug --with-zlib \
--disable-dependency-tracking
make -j${JOBS}
make install
export LDFLAGS=${OLD_LDFLAGS}
cd ${PACKAGES}

check_and_clear_libs
