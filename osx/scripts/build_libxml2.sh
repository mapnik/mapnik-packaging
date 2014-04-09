#!/bin/bash
set -e -u
set -o pipefail
mkdir -p ${PACKAGES}
cd ${PACKAGES}

download libxml2-${LIBXML2_VERSION}.tar.gz

echoerr 'building libxml2'
rm -rf libxml2-${LIBXML2_VERSION}
tar xf libxml2-${LIBXML2_VERSION}.tar.gz
cd libxml2-${LIBXML2_VERSION}
if [ ${PLATFORM} = 'Android' ]; then
    mkdir ./tmp
    cd ./tmp
    cp ${PATCHES}/glob.c .
    cp ${PATCHES}/glob.h .
    ${CC} -c -I. ${CFLAGS} glob.c -Wall -Wextra
    chmod +x glob.o
    RIGHT_HERE=$(pwd)
    LIBS="${RIGHT_HERE}/glob.o"
    CFLAGS="${CFLAGS} -I${RIGHT_HERE}"
    cd ../
fi
# note --with-writer for osmium
./configure --prefix=${BUILD} \
--enable-static --disable-shared ${HOST_ARG} \
--with-writer \
--with-xptr \
--with-xpath \
--with-xinclude \
--with-threads \
--with-tree \
--with-catalog \
--without-icu \
--without-zlib \
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
cd ${PACKAGES}

check_and_clear_libs