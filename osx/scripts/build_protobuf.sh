#!/bin/bash
set -e -u -x

mkdir -p ${PACKAGES}
cd ${PACKAGES}

download protobuf-${PROTOBUF_VERSION}.tar.bz2

echoerr 'building protobuf C++'
rm -rf protobuf-${PROTOBUF_VERSION}-${ARCH_NAME}
tar xf protobuf-${PROTOBUF_VERSION}.tar.bz2
mv protobuf-${PROTOBUF_VERSION} protobuf-${PROTOBUF_VERSION}-${ARCH_NAME}
cd protobuf-${PROTOBUF_VERSION}-${ARCH_NAME}
if [ $BOOST_ARCH = "arm" ]; then
    if [ -f "$(pwd)/../protobuf-${PROTOBUF_VERSION}-i386/src/protoc" ]; then
        NATIVE_PROTOC="$(pwd)/../protobuf-${PROTOBUF_VERSION}-i386/src/protoc"
    elif [ -f "$(pwd)/../protobuf-${PROTOBUF_VERSION}-x86-64/src/protoc" ]; then
        NATIVE_PROTOC="$(pwd)/../protobuf-${PROTOBUF_VERSION}-x86-64/src/protoc"
    else
        echoerr 'could not find pre-built protobuf/protoc from a native/host arch!'
    fi
    export CROSS_FLAGS="--with-protoc=${NATIVE_PROTOC}"
else
    export CROSS_FLAGS=""
fi
export OLD_LDFLAGS=${LDFLAGS}
export LDFLAGS="${STDLIB_LDFLAGS} ${LDFLAGS}"
export OLD_CXX=${CXX}
# note: we put ${STDLIB_CXXFLAGS} into CXX instead of CXXFLAGS due to libtool oddity:
# http://stackoverflow.com/questions/16248360/autotools-libtool-link-library-with-libstdc-despite-stdlib-libc-option-pass
export CXX="${CXX} ${STDLIB_CXXFLAGS}"
# WARNING: building a shared lib will result in shared libs being listed in
# the libprotobuf.la and then libproto-c will try to link against them even
# if they do not exist (as deleted by below)
./configure --prefix=${BUILD} ${HOST_ARG} ${CROSS_FLAGS} \
--enable-static --disable-shared \
--disable-debug --with-zlib \
--disable-dependency-tracking
make -j${JOBS}
make install
export LDFLAGS=${OLD_LDFLAGS}
export CXX=${OLD_CXX}
cd ${PACKAGES}

check_and_clear_libs
