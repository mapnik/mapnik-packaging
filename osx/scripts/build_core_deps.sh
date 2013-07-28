set -e 

mkdir -p ${PACKAGES}
cd ${PACKAGES}

# icu
echo '*building icu*'
rm -rf icu-${ARCH_NAME}
rm -rf icu
# *WARNING* do not set an $INSTALL variable
# it will screw up icu build scripts
export OLD_CPPFLAGS=${CPPFLAGS}
export OLD_LDFLAGS=${LDFLAGS}
export LDFLAGS="${STDLIB_LDFLAGS} ${LDFLAGS}"
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
--enable-shared \
--with-data-packaging=archive
make -j${JOBS}
make install
export LDFLAGS=${OLD_LDFLAGS}
export CPPFLAGS=${OLD_CPPFLAGS}
cd ${PACKAGES}

if [ $UNAME = 'Darwin' ]; then
    otool -L ${BUILD}/lib/*.dylib | grep c++
fi

# clear out shared libs
rm -f ${BUILD}/lib/{*.so,*.dylib}


# boost
echo '*building boost*'
B2_VERBOSE="-d0"
#B2_VERBOSE="-d2"
rm -rf boost_${BOOST_VERSION2}-${ARCH_NAME}
tar xjf boost_${BOOST_VERSION2}.tar.bz2
mv boost_${BOOST_VERSION2} boost_${BOOST_VERSION2}-${ARCH_NAME}
cd boost_${BOOST_VERSION2}-${ARCH_NAME}

if [ $UNAME = 'Darwin' ]; then
  # patch python build to ensure we do not link boost_python to python
  patch -N tools/build/v2/tools/python.jam < ${PATCHES}/python_jam.diff
  # https://svn.boost.org/trac/boost/ticket/6686
  if [[ -d /Applications/Xcode.app/Contents/Developer ]]; then
      patch -N tools/build/v2/tools/darwin.jam ${PATCHES}/boost_sdk.diff
  fi
fi

echo "using ${BOOST_TOOLSET} ;" > user-config.jam

echo '*bootstrapping boost*'
./bootstrap.sh

# HINT: problems with icu configure check?
# cat bin.v2/config.log to see problems

if [ $BOOST_ARCH = "arm" ]; then
    export CROSS_FLAGS=""
    export EXTRA_LIBS_ARGS=""
else
    export CROSS_FLAGS="tools/bcp"
    export EXTRA_LIBS_ARGS="--with-program_options"
fi

# TODO set address-model ?

# only build with icudata library support on mac
if [ $BOOST_ARCH = "x86" ]; then
    export BOOST_LDFLAGS="${STDLIB_LDFLAGS} ${LDFLAGS} -L${BUILD}/lib -licuuc -licui18n -licudata"
    export BOOST_CXXFLAGS="${CXXFLAGS} -DU_STATIC_IMPLEMENTATION=1"
    export ICU_DETAILS='-sHAVE_ICU=1 -sICU_PATH=${BUILD}'
else
    echo '#error' > libs/regex/build/has_icu_test.cpp
    export BOOST_LDFLAGS="${STDLIB_LDFLAGS} ${LDFLAGS}"
    export BOOST_CXXFLAGS="${CXXFLAGS}"
    export ICU_DETAILS=""
fi

echo '*compiling boost*'
# static libs
./b2 ${CROSS_FLAGS} \
  --prefix=${BUILD} -j${JOBS} ${B2_VERBOSE} \
  --ignore-site-config --user-config=user-config.jam \
  architecture="${BOOST_ARCH}" \
  toolset="${BOOST_TOOLSET}" \
  --with-thread \
  --with-filesystem \
  --disable-filesystem2 \
  --with-system \
  ${EXTRA_LIBS_ARGS} \
  ${ICU_DETAILS} \
  --with-regex \
  link=static,shared \
  variant=release \
  linkflags="${BOOST_LDFLAGS}" \
  cxxflags="${BOOST_CXXFLAGS}" \
  stage install

if [ $UNAME = 'Darwin' ]; then
    otool -L ${BUILD}/lib/*.dylib | grep c++
fi

# clear out shared libs
rm -f ${BUILD}/lib/{*.so,*.dylib}
cd ${PACKAGES}
echo '*done compiling boost*'


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
# no longer needed on os x with zlib 1.2.8
#if [ $UNAME = 'Darwin' ]; then
#  patch -N < ${PATCHES}/zlib-configure.diff
#fi
./configure --prefix=${BUILD}
make -j$JOBS
make install
cd ${PACKAGES}

# clear out shared libs
rm -f ${BUILD}/lib/{*.so,*.dylib}

# freetype
echo '*building freetype*'
rm -rf freetype-${FREETYPE_VERSION}
tar xf freetype-${FREETYPE_VERSION}.tar.bz2
cd freetype-${FREETYPE_VERSION}
./configure --prefix=${BUILD} --enable-static --disable-shared ${HOST_ARG}
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
./configure --prefix=${BUILD} --with-zlib=${PREFIX} \
--enable-static --disable-shared ${HOST_ARG} \
--with-icu=${PREFIX} \
--without-python \
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


if [ $UNAME = 'Darwin' ]; then
    lipo -info ${BUILD}/lib/*.a | grep arch
fi