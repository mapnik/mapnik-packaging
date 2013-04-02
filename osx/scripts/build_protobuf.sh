cd ${PACKAGES}
echo '*building protobuf C++*'
rm -rf protobuf-${PROTOBUF_VERSION}-${ARCH_NAME}
tar xf protobuf-${PROTOBUF_VERSION}.tar.bz2
mv protobuf-${PROTOBUF_VERSION} protobuf-${PROTOBUF_VERSION}-${ARCH_NAME}
cd protobuf-${PROTOBUF_VERSION}-${ARCH_NAME}
if [ $BOOST_ARCH = "arm" ]; then
    export CROSS_FLAGS="--with-protoc=$(pwd)/../protobuf-${PROTOBUF_VERSION}-i386/src/protoc"
else
    export CROSS_FLAGS=""
fi
./configure --prefix=${BUILD} ${HOST_ARG} ${CROSS_FLAGS} \
--enable-static --disable-shared \
--disable-debug --with-zlib \
--disable-dependency-tracking
make -j${JOBS}
make install
cd ${PACKAGES}
