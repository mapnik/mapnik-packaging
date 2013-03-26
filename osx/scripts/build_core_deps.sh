set -e 

mkdir -p ${BUILD}
cd ${PACKAGES}

# bzip2
echo '*building bzip2'
rm -rf bzip2-${BZIP2_VERSION}
tar xf bzip2-${BZIP2_VERSION}.tar.gz
cd bzip2-${BZIP2_VERSION}
make install PREFIX=${BUILD} CC="$CC" CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS"
cd ${PACKAGES}

# zlib
echo '*building zlib*'
rm -rf zlib-${ZLIB_VERSION}
tar xf zlib-${ZLIB_VERSION}.tar.gz
cd zlib-${ZLIB_VERSION}
patch < ${ROOTDIR}/patches/zlib-configure.diff
./configure --prefix=${BUILD} --static
make -j$JOBS
make install
cd ${PACKAGES}

# freetype
echo '*building freetype*'
rm -rf freetype-${FREETYPE_VERSION}
tar xf freetype-${FREETYPE_VERSION}.tar.bz2
cd freetype-${FREETYPE_VERSION}
./configure --prefix=${BUILD} --enable-static --disable-shared ${HOST_ARG}
make -j${JOBS}
make install
cd ${PACKAGES}

# libpng
echo '*building libpng*'
rm -rf libpng-${LIBPNG_VERSION}
tar xf libpng-${LIBPNG_VERSION}.tar.gz
cd libpng-${LIBPNG_VERSION}
./configure --prefix=${BUILD} --enable-static --disable-shared ${HOST_ARG} --disable-dependency-tracking
make -j${JOBS}
make install
cd ${PACKAGES}

# libtool - for libltdl
echo '*building libltdl'
rm -rf libtool-${LIBTOOL_VERSION}
tar xf libtool-${LIBTOOL_VERSION}.tar.gz
cd libtool-${LIBTOOL_VERSION}
./configure --prefix=${BUILD} --enable-static --disable-shared ${HOST_ARG}
make -j$JOBS
make install
cd ${PACKAGES}


# icu
echo '*building icu*'
rm -rf icu/source-${ARCH_NAME}
# *WARNING* do not set an $INSTALL variable
# it will screw up icu build scripts
export OLD_CPPFLAGS=${CPPFLAGS}
# U_CHARSET_IS_UTF8 is added to try to reduce icu library size (18.3)
# custom include paths are needed for cross-build
export CPPFLAGS="-DU_CHARSET_IS_UTF8=1 -I$(pwd)/icu/source-${ARCH_NAME}/common -I$(pwd)/icu/source-${ARCH_NAME}/tools/tzcode/"
tar xf icu4c-${ICU_VERSION2}-src.tgz
mv icu/source icu/source-${ARCH_NAME}
cd icu/source-${ARCH_NAME}
if [ $BOOST_ARCH = "arm" ]; then
    export CROSS_FLAGS="--with-cross-build=$(pwd)/../source-i386"
else
    export CROSS_FLAGS=""
fi
./configure ${HOST_ARG} $CROSS_FLAGS --prefix=${BUILD} \
--disable-samples \
--enable-static \
--disable-shared \
--with-data-packaging=archive
make -j${JOBS}
make install
export CPPFLAGS=${OLD_CPPFLAGS}
cd ${PACKAGES}


# libxml2
echo '*building libxml2*'
rm -rf libxml2-${LIBXML2_VERSION}
tar xf libxml2-${LIBXML2_VERSION}.tar.gz
cd libxml2-${LIBXML2_VERSION}
patch threads.c ${ROOTDIR}/patches/libxml2-pthread.diff -N
./configure --prefix=${BUILD} --with-zlib=${PREFIX} \
--enable-static --disable-shared ${HOST_ARG} \
--with-icu=${PREFIX} \
--with-xptr \
--with-xpath \
--with-xinclude \
--with-threads \
--with-tree \
--with-catalog \
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
--without-writer \
--without-modules \
--without-lzma \
--without-readline \
--without-regexps \
--without-c14n
make -j${JOBS}
make install
cd ${PACKAGES}

# boost
echo '*building boost*'
B2_VERBOSE="-d0"
#B2_VERBOSE="-d2"
rm -rf boost_${BOOST_VERSION2}
tar xjf boost_${BOOST_VERSION2}.tar.bz2
cd boost_${BOOST_VERSION2}
# patch python build to ensure we do not link boost_python to python
patch tools/build/v2/tools/python.jam < ${ROOTDIR}/patches/python_jam.diff
./bootstrap.sh
echo 'using clang-darwin ;' > user-config.jam

# https://svn.boost.org/trac/boost/ticket/6686
if [[ -d /Applications/Xcode.app/Contents/Developer ]]; then
    patch tools/build/v2/tools/darwin.jam ${ROOTDIR}/patches/boost_sdk.diff
fi

# HINT: problems with icu configure check?
# cat bin.v2/config.log to see problems

# static libs
./b2 tools/bcp \
  --prefix=${BUILD} -j${JOBS} ${B2_VERBOSE} \
  --ignore-site-config --user-config=user-config.jam \
  toolset=clang \
  --with-thread \
  --with-filesystem \
  --disable-filesystem2 \
  --with-program_options --with-system --with-chrono \
  architecture=${BOOST_ARCH} \
  link=static \
  variant=release \
  stage install \
  linkflags="${LDFLAGS} -L${BUILD}/lib -licuuc -licui18n -licudata" \
  cxxflags="${CXXFLAGS} -DU_STATIC_IMPLEMENTATION=1" \
  -sHAVE_ICU=1 -sICU_PATH=${BUILD} \
  --with-regex

lipo -info ${BUILD}/lib/*.a | grep arch