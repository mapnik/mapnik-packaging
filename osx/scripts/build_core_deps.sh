set -e 

mkdir -p ${BUILD}
cd ${PACKAGES}

# icu
echo '*building icu*'
rm -rf icu-${ARCH_NAME}
# *WARNING* do not set an $INSTALL variable
# it will screw up icu build scripts
export OLD_CPPFLAGS=${CPPFLAGS}
# U_CHARSET_IS_UTF8 is added to try to reduce icu library size (18.3)
export CPPFLAGS="-DU_CHARSET_IS_UTF8=1"
tar xf icu4c-${ICU_VERSION2}-src.tgz
mv icu icu-${ARCH_NAME}
cd icu-${ARCH_NAME}/source
if [ $BOOST_ARCH = "arm" ]; then
    export CROSS_FLAGS="--with-cross-build=$(pwd)/../../icu-i386/source"
    export CPPFLAGS="${CPPFLAGS} -I$(pwd)/common -I$(pwd)/tools/tzcode/"
else
    export CROSS_FLAGS=""
fi
./configure ${HOST_ARG} ${CROSS_FLAGS} --prefix=${BUILD} \
--disable-samples \
--enable-static \
--disable-shared \
--with-data-packaging=archive
make -j${JOBS}
make install
export CPPFLAGS=${OLD_CPPFLAGS}
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
patch -N < ${PATCHES}/zlib-configure.diff
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

# libxml2
echo '*building libxml2*'
rm -rf libxml2-${LIBXML2_VERSION}
tar xf libxml2-${LIBXML2_VERSION}.tar.gz
cd libxml2-${LIBXML2_VERSION}
patch -N threads.c ${PATCHES}/libxml2-pthread.diff
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
rm -rf boost_${BOOST_VERSION2}-${ARCH_NAME}
tar xjf boost_${BOOST_VERSION2}.tar.bz2
mv boost_${BOOST_VERSION2} boost_${BOOST_VERSION2}-${ARCH_NAME}
cd boost_${BOOST_VERSION2}-${ARCH_NAME}
# patch python build to ensure we do not link boost_python to python
patch -N tools/build/v2/tools/python.jam < ${PATCHES}/python_jam.diff
echo 'using clang-darwin ;' > user-config.jam
./bootstrap.sh

# https://svn.boost.org/trac/boost/ticket/6686
if [[ -d /Applications/Xcode.app/Contents/Developer ]]; then
    patch -N tools/build/v2/tools/darwin.jam ${PATCHES}/boost_sdk.diff
fi

# HINT: problems with icu configure check?
# cat bin.v2/config.log to see problems

if [ $BOOST_ARCH = "arm" ]; then
    export CROSS_FLAGS=""
    export EXTRA_LIBS_ARGS=""
else
    export CROSS_FLAGS="tools/bcp"
    export EXTRA_LIBS_ARGS="--with-program_options --with-chrono"
fi

# static libs
echo '#error' > libs/regex/build/has_icu_test.cpp
./b2 ${CROSS_FLAGS} \
  --prefix=${BUILD} -j${JOBS} ${B2_VERBOSE} \
  --ignore-site-config --user-config=user-config.jam \
  architecture=${BOOST_ARCH} \
  toolset=clang \
  --with-thread \
  --with-filesystem \
  --disable-filesystem2 \
  --with-system \
  $EXTRA_LIBS_ARGS \
  --disable-icu \
  --with-regex \
  link=static \
  variant=release \
  linkflags="${LDFLAGS}" \
  cxxflags="${CXXFLAGS}" \
  stage install

: '
./b2 ${CROSS_FLAGS} \
  --prefix=${BUILD} -j${JOBS} ${B2_VERBOSE} \
  --ignore-site-config --user-config=user-config.jam \
  architecture=${BOOST_ARCH} \
  toolset=clang \
  --with-thread \
  --with-filesystem \
  --disable-filesystem2 \
  --with-program_options --with-system --with-chrono \
  link=static \
  variant=release \
  linkflags="${LDFLAGS} -L${BUILD}/lib -licuuc -licui18n -licudata" \
  cxxflags="${CXXFLAGS} -DU_STATIC_IMPLEMENTATION=1" \
  -sHAVE_ICU=1 -sICU_PATH=${BUILD} \
  --with-regex \
  stage install
'

lipo -info ${BUILD}/lib/*.a | grep arch