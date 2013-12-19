#!/bin/bash
set -e -u -x

mkdir -p ${PACKAGES}
cd ${PACKAGES}

download libxml2-${LIBXML2_VERSION}.tar.gz

echoerr 'building libxml2'
rm -rf libxml2-${LIBXML2_VERSION}
tar xf libxml2-${LIBXML2_VERSION}.tar.gz
cd libxml2-${LIBXML2_VERSION}
export OLD_CFLAGS="${CFLAGS}"
if [ ${PLATFORM} = 'Android' ]; then
    mkdir ./tmp
    cd ./tmp
    cp ${PATCHES}/glob.c .
    cp ${PATCHES}/glob.h .
    ${CC} -c -I. ${CFLAGS} glob.c -Wall -Wextra
    chmod +x glob.o
    RIGHT_HERE=$(pwd)
    export LIBS="${RIGHT_HERE}/glob.o"
    export CFLAGS="${CFLAGS} -I${RIGHT_HERE}"
    cd ../
fi
# note --with-writer for osmium
./configure --prefix=${BUILD} --with-zlib=${BUILD} \
--enable-static --disable-shared ${HOST_ARG} \
--with-icu=${BUILD} \
--with-writer \
--with-xptr \
--with-xpath \
--with-xinclude \
--with-threads \
--with-tree \
--with-catalog \
--without-python \
--without-legacy \
--without-iconv \
--without-debug \
--without-docbook \
--without-ftp \
--without-html \
--without-http \
--without-sax1 \
--without-schemas \
--without-schematron \
--without-valid \
--without-modules \
--without-lzma \
--without-readline \
--without-regexps \
--without-c14n
make -j${JOBS} install
unset LIBS
export CFLAGS="${OLD_CFLAGS}"
cd ${PACKAGES}

check_and_clear_libs