cd ${PACKAGES}
echo '*building protobuf C++*'
rm -rf cd protobuf-${PROTOBUF_VERSION}
tar xf protobuf-${PROTOBUF_VERSION}.tar.bz2
cd protobuf-${PROTOBUF_VERSION}
./configure --prefix=${BUILD} ${HOST_ARG} \
--enable-static --disable-shared \
--disable-debug --with-zlib \
--disable-dependency-tracking
make -j${JOBS}
make install
cd ${PACKAGES}
