set -e 

mkdir -p ${PACKAGES}
cd ${PACKAGES}

# icu
${ROOTDIR}/scripts/build_icu.sh

# boost
${ROOTDIR}/scripts/build_boost.sh

# bzip2
echo '*building bzip2'
rm -rf bzip2-${BZIP2_VERSION}
tar xf bzip2-${BZIP2_VERSION}.tar.gz
cd bzip2-${BZIP2_VERSION}
# note: -i -k only for android since ranlib breaks: error: bz2: no archive symbol table (run ranlib)
make install PREFIX=${BUILD} CC="$CC" CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS" RANLIB="${RANLIB}" -i -k
if [ ${PLATFORM} = 'Android' ]; then
    ${RANLIB} ${BUILD}/lib/libbz2.a
fi
cd ${PACKAGES}

# zlib
echo '*building zlib*'
rm -rf zlib-${ZLIB_VERSION}
tar xf zlib-${ZLIB_VERSION}.tar.gz
cd zlib-${ZLIB_VERSION}
# no longer needed on os x with zlib 1.2.8
#if [ $UNAME = 'Darwin' ]; then
#  patch -N < ${PATCHES}/zlib-configure.diff
#fi
if [ ${PLATFORM} = 'Android' ]; then
   patch -N < ${PATCHES}/android-zlib.diff
fi
./configure --prefix=${BUILD}
make -j$JOBS
make install
cd ${PACKAGES}

check_and_clear_libs

# freetype
echo '*building freetype*'
rm -rf freetype-${FREETYPE_VERSION}
tar xf freetype-${FREETYPE_VERSION}.tar.bz2
cd freetype-${FREETYPE_VERSION}
./configure --prefix=${BUILD} --enable-static --disable-shared ${HOST_ARG} \
 --without-bzip2 \
 --without-png
make -j${JOBS}
make install
cd ${PACKAGES}

# jpeg
echo '*building jpeg*'
rm -rf jpeg-${JPEG_VERSION}
tar xf jpegsrc.v${JPEG_VERSION}.tar.gz
cd jpeg-${JPEG_VERSION}
./configure --prefix=${BUILD} --enable-static --disable-shared ${HOST_ARG} --disable-dependency-tracking
make -j${JOBS}
make install
cd ${PACKAGES}

# libpng
echo '*building libpng*'
rm -rf libpng-${LIBPNG_VERSION}
tar xf libpng-${LIBPNG_VERSION}.tar.gz
cd libpng-${LIBPNG_VERSION}
# NOTE: C_INCLUDE_PATH is needed for png the gcc -E usage which does not
# seem to respect CFLAGS and will fail to find zlib.h
./configure --prefix=${BUILD} --enable-static --disable-shared ${HOST_ARG} \
  --disable-dependency-tracking \
  --with-zlib-prefix=${BUILD}
make -j${JOBS}
make install
cd ${PACKAGES}

# libxml2
echo '*building libxml2*'
rm -rf libxml2-${LIBXML2_VERSION}
tar xf libxml2-${LIBXML2_VERSION}.tar.gz
cd libxml2-${LIBXML2_VERSION}
export OLD_LIBS="${LIBS}"
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
./configure --prefix=${BUILD} --with-zlib=${PREFIX} \
--enable-static --disable-shared ${HOST_ARG} \
--with-icu=${PREFIX} \
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
export LIBS="${OLD_LIBS}"
export CFLAGS="${OLD_CFLAGS}"
cd ${PACKAGES}

check_and_clear_libs