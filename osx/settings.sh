#!/bin/bash

# settings
export OFFICIAL_RELEASE='false'
export USE_BOOST_TRUNK='false'

# start from here
export ROOTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

export UNAME=$(uname -s);
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:${PATH}"

export DARWIN_VERSION=$(uname -r)
export LIBCXX_DEFAULT=false
if [ ${UNAME} = 'Darwin' ]; then
  SEMVER_PATTERN='[^0-9]*\([0-9]*\)[.]\([0-9]*\)[.]\([0-9]*\)\([0-9A-Za-z-]*\)'
  DARWIN_MAJOR=`echo $DARWIN_VERSION | sed -e "s#$SEMVER_PATTERN#\1#"`
  if [ ${DARWIN_MAJOR} = "13" ];then
    export LIBCXX_DEFAULT=true
  fi
fi

# note: -DUCONFIG_NO_BREAK_ITERATION=1 is desired by mapnik (for toTitle)
# http://www.icu-project.org/apiref/icu4c/uconfig_8h_source.html
export ICU_CORE_CPP_FLAGS="-DU_CHARSET_IS_UTF8=1"
# disabled due to breakage with node-mapnik on OS X: https://github.com/mapnik/mapnik-packaging/issues/98
# -DU_USING_ICU_NAMESPACE=0 -DU_STATIC_IMPLEMENTATION=1 -DU_TIMEZONE=0 -DUCONFIG_NO_LEGACY_CONVERSION=1 -DUCONFIG_NO_FORMATTING=1 -DUCONFIG_NO_TRANSLITERATION=1 -DUCONFIG_NO_REGULAR_EXPRESSIONS=1"
export ICU_EXTRA_CPP_FLAGS="${ICU_CORE_CPP_FLAGS} -DUCONFIG_NO_COLLATION=1"

export OPTIMIZATION="3"
export S3_BASE="http://mapnik.s3.amazonaws.com/deps"
export MAPNIK_DIST="${ROOTDIR}/out/dist"
export PACKAGES="${ROOTDIR}/out/packages"
export PATCHES="${ROOTDIR}/patches"
export STAGING="${ROOTDIR}/out/staging"
export MAPNIK_INSTALL="/usr/local"
export MAPNIK_PACKAGE_PREFIX="mapnik"

# http://apps.icu-project.org/datacustom/
export PREMADE_ICU_DATA_LIBRARY="${ROOTDIR}/icudt52l_only_collator_and_breakiterator.dat"

if [ ${PLATFORM} = 'Linux' ]; then
    export EXTRA_CFLAGS="-fPIC"
    if [ "${CXX11}" = true ]; then
        if [ "${CXX:-false}" = "clang++" ]; then
            # workaround http://llvm.org/bugs/show_bug.cgi?id=13530#c3
            export EXTRA_CFLAGS="${EXTRA_CFLAGS} -D__float128=void"
        fi
    fi
    export EXTRA_CXXFLAGS="${EXTRA_CFLAGS}"
    # TODO -Wl,--gc-sections
    # Note: stripping with -Wl,-S breaks dtrace
    export EXTRA_LDFLAGS="-Wl,--as-needed"
    if [ "${CXX:-false}" = "clang++" ]; then
      export CORE_CC="clang"
      export CORE_CXX="clang++"
    else
      export CORE_CC="gcc"
      export CORE_CXX="g++"
    fi
    export AR=ar
    export RANLIB=ranlib
    export ARCH_FLAGS=
    export JOBS=`grep -c ^processor /proc/cpuinfo`
    export BOOST_TOOLSET="gcc"
    export CXX_VISIBILITY_FLAGS="-fvisibility-inlines-hidden"
    if [ "${CXX11}" = true ]; then
      export STDLIB="libstdc++"
      export STDLIB_CXXFLAGS="-std=c++11 -DBOOST_SPIRIT_USE_PHOENIX_V3=1"
      export STDLIB_LDFLAGS=""
      echo "building against libstdc++ in c++11 mode"
    else
      echo "building against libstdc++"
      export STDLIB="libstdc++"
      export STDLIB_CXXFLAGS=""
      export STDLIB_LDFLAGS=""
    fi
elif [ ${PLATFORM} = 'Android' ]; then
    export UNAME='Android'
    export API_LEVEL="android-18"
    export ANDROID_CROSS_COMPILER="arm-linux-androideabi-4.8"
    # run ./scripts/setup-android-ndk-adk-osx.sh to setup
    export NDK_PATH="${PACKAGES}/android-ndk-r9"
    #ln -s ../android/android-ndk-r9 ./android-ndk-r9
    export PLATFORM_PREFIX="${NDK_PATH}/active-platform/"
    # NOTE: make-standalone-toolchain.sh --help for options
    if [ ! -d "${PLATFORM_PREFIX}" ]; then
        echo "creating android toolchain with ${ANDROID_CROSS_COMPILER}/${API_LEVEL} at ${PLATFORM_PREFIX}"
        "${NDK_PATH}/build/tools/make-standalone-toolchain.sh"  \
          --toolchain="${ANDROID_CROSS_COMPILER}" \
          --install-dir="${PLATFORM_PREFIX}" \
          --stl=gnustl \
          --arch=arm \
          --platform="${API_LEVEL}"
    fi
    export ICU_EXTRA_CPP_FLAGS="${ICU_EXTRA_CPP_FLAGS} -DU_HAVE_NL_LANGINFO_CODESET=0"
    alias ldd="arm-linux-androideabi-readelf -d "
    export EXTRA_CFLAGS="-fPIC -D_LITTLE_ENDIAN"
    export EXTRA_CXXFLAGS="${EXTRA_CFLAGS}"
    export EXTRA_LDFLAGS=""
    export JOBS=`sysctl -n hw.ncpu`
    export BOOST_TOOLSET="gcc-arm"
    export SDK_PATH=
    export PATH="${PLATFORM_PREFIX}/bin":${PATH}
    export CORE_CXX="arm-linux-androideabi-g++"
    export CORE_CC="arm-linux-androideabi-gcc"
    export LD="arm-linux-androideabi-ld"
    export AR="arm-linux-androideabi-ar"
    export ARCH_FLAGS=
    export RANLIB="arm-linux-androideabi-ranlib"
    # TODO - some builds hardcode libtool which breaks since os x version is used (zlib)
    #alias libtool="arm-linux-androideabi-ar cru"
    #export libtool="arm-linux-androideabi-ar cru"
    export NM="arm-linux-androideabi-nm"
    echo "building against libstdc++"
    export STDLIB="libstdc++"
    export STDLIB_CXXFLAGS=""
    export STDLIB_LDFLAGS=""
elif [ ${UNAME} = 'Darwin' ]; then
    # NOTE: supporting 10.6 on OS X 10.8 requires copying old 10.6 SDK into:
    # /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/
    export XCODE_PREFIX=$( xcode-select -print-path )
    if [ -d "${XCODE_PREFIX}" ]; then
      # set this up with:
      #   sudo xcode-select -switch /Applications/Xcode.app/Contents/Developer
      # for more info
      #   man xcrun
      export TOOLCHAIN_ROOT="${XCODE_PREFIX}/Toolchains/XcodeDefault.xctoolchain/usr/bin"
      export CORE_CC="${TOOLCHAIN_ROOT}/clang"
      export CORE_CXX="${XCODE_PREFIX}/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang++"
      export SDK_ROOT="${XCODE_PREFIX}/Platforms/${PLATFORM}.platform/Developer"
      # /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer
      export PLATFORM_SDK="${PLATFORM}${ACTIVE_SDK_VERSION}.sdk"
      export SDK_PATH="${SDK_ROOT}/SDKs/${PLATFORM_SDK}" ## >= 4.3.1 from MAC
      export EXTRA_CFLAGS="${MIN_SDK_VERSION_FLAG} -isysroot ${SDK_PATH}"
      # Note: stripping with -Wl,-S breaks dtrace
      export EXTRA_LDFLAGS="${MIN_SDK_VERSION_FLAG} -isysroot ${SDK_PATH} -Wl,-search_paths_first"
    else
      export TOOLCHAIN_ROOT="/usr/bin"
      export CORE_CC="${TOOLCHAIN_ROOT}/clang"
      export CORE_CXX="${TOOLCHAIN_ROOT}/clang++"
      export EXTRA_CFLAGS=""
      # todo -no_dead_strip_inits_and_terms
      export EXTRA_LDFLAGS="-Wl,-search_paths_first"
    fi
    export ARCH_FLAGS="-arch ${ARCH_NAME}"
    export PATH=${TOOLCHAIN_ROOT}:$PATH
    export EXTRA_CXXFLAGS="${EXTRA_CFLAGS}"
    export JOBS=`sysctl -n hw.ncpu`
    export BOOST_TOOLSET="clang"
    # warning this breaks some c++ linking, like v8 mksnapshot since it then links as C
    # and needs to default to 'gyp-mac-tool'
    #export LD="clang"
    unset LD
    unset AR
    unset RANLIB
    # breaks node.js -fvisibility=hidden and partially breaks gdal bin programs
    export CXX_VISIBILITY_FLAGS="-fvisibility-inlines-hidden"
    if [ "${CXX11}" = true ]; then
        export STDLIB="libc++"
        export STDLIB_CXXFLAGS="-std=c++11 -stdlib=libc++"
        export STDLIB_LDFLAGS="-stdlib=libc++" #-lc++ -lc++abi
        echo "building against ${STDLIB} in c++11 mode"
    else
        if [ "${LIBCXX_DEFAULT}" = true ]; then
            export STDLIB="libc++"
        else
            export STDLIB="libstdc++"
        fi
        export STDLIB_CXXFLAGS="-Wno-c++11-long-long"
        export STDLIB_LDFLAGS=""
        echo "building against ${STDLIB} in ANSI mode"
    fi
else
    echo '**unhandled platform: ${PLATFORM}**'
fi

export MAPNIK_SOURCE="${ROOTDIR}/mapnik-${STDLIB}"
export BUILDDIR="build-${STDLIB}"
export BUILD_UNIVERSAL="${ROOTDIR}/out/${BUILDDIR}-universal"
export BUILD_ROOT="${ROOTDIR}/out/${BUILDDIR}"
export BUILD="${BUILD_ROOT}-${ARCH_NAME}"
export MAPNIK_DESTDIR="${BUILD}-mapnik"
export MAPNIK_BIN_SOURCE="${MAPNIK_DESTDIR}${MAPNIK_INSTALL}"
export PATH="${MAPNIK_BIN_SOURCE}/bin:${MAPNIK_SOURCE}/utils/mapnik-config:${PATH}"

# should not be needed now that we set 'LIBRARY_PATH'
#if [ $UNAME = 'Darwin' ]; then
  #export DYLD_LIBRARY_PATH="${BUILD}/lib"
#fi

export PKG_CONFIG_PATH="${BUILD}/lib/pkgconfig"
export PATH="${BUILD}/bin:$PATH"

if [[ $JOBS > 4 ]]; then
    export JOBS=$(expr $JOBS - 2)
fi

export ARCHFLAGS="${ARCH_FLAGS}"
export CORE_CPPFLAGS=""
export DEBUG_FLAGS="-DNDEBUG"
export CORE_CFLAGS="${DEBUG_FLAGS} -O${OPTIMIZATION} ${ARCH_FLAGS} -D_FILE_OFFSET_BITS=64"
export CORE_CXXFLAGS="${CXX_VISIBILITY_FLAGS} ${CORE_CFLAGS}"
export CORE_LDFLAGS="-O${OPTIMIZATION} ${ARCH_FLAGS}"

export CXX="${CORE_CXX}"
export CC="${CORE_CC}"
export C_INCLUDE_PATH="${BUILD}/include"
export CPLUS_INCLUDE_PATH="${BUILD}/include"
export LIBRARY_PATH="${BUILD}/lib"
export CPPFLAGS="${CORE_CPPFLAGS}"
export LDFLAGS="-L${BUILD}/lib $CORE_LDFLAGS $EXTRA_LDFLAGS"
# CMAKE systems ignore LDFLAGS but accept LINK_FLAGS
export LINK_FLAGS=${LDFLAGS}
export CFLAGS="-I${BUILD}/include $CORE_CFLAGS $EXTRA_CFLAGS"
export CXXFLAGS="${STDLIB_CXXFLAGS} -I${BUILD}/include $CORE_CXXFLAGS $EXTRA_CXXFLAGS"

# http://site.icu-project.org/download
export ICU_VERSION="52.1"
export ICU_VERSION2="52_1"

export BOOST_VERSION="1.55.0"
export BOOST_VERSION2="1_55_0"
# http://www.sqlite.org/download.html
export SQLITE_VERSION="3080200"
# http://download.savannah.gnu.org/releases/freetype/
export FREETYPE_VERSION="2.5.2"
# http://download.osgeo.org/proj/
export PROJ_VERSION="4.8.0"
# TODO - test proj-datumgrid-1.6RC1.zip
export PROJ_GRIDS_VERSION="1.5"
# http://www.libpng.org/pub/png/libpng.html
export LIBPNG_VERSION="1.6.7"
# http://download.osgeo.org/libtiff/
export LIBTIFF_VERSION="4.0.3"
# https://code.google.com/p/webp/downloads/list
export WEBP_VERSION="0.3.1"
# http://download.osgeo.org/geotiff/libgeotiff/
export LIBGEOTIFF_VERSION="1.4.0"
export JPEG_VERSION="8d"
export EXPAT_VERSION="2.1.0"
# http://download.osgeo.org/gdal/CURRENT/
export GDAL_VERSION="1.10.1"
export GETTEXT_VERSION="0.18.1.1"
# http://ftp.postgresql.org/pub/source/
export POSTGRES_VERSION="9.3.1"
# http://zlib.net/zlib-1.2.8.tar.gz
export ZLIB_VERSION="1.2.8"
# ftp://xmlsoft.org/libxml2/
export LIBXML2_VERSION="2.9.1"
export BZIP2_VERSION="1.0.6"
export PKG_CONFIG_VERSION="0.25"
export FONTCONFIG_VERSION="2.10.0"
# http://cairographics.org/releases/
export PIXMAN_VERSION="0.30.0"
export CAIRO_VERSION="1.12.16"
export PY2CAIRO_VERSION="1.10.0"
export PY3CAIRO_VERSION="1.10.0"
# http://download.osgeo.org/geos/
export GEOS_VERSION="3.4.2"
export PROTOBUF_VERSION="2.5.0"
export PROTOBUF_C_VERSION="0.15"
export XZ_VERSION="5.0.3"
export NOSE_VERSION="1.2.1"
export NODE_VERSION="0.10.24"
export SPARSEHASH_VERSION="2.0.2"
export HARFBUZZ_VERSION="0.9.25"
export STXXL_VERSION="1.4.0"
export LUABIND_VERSION="0.9.1"
export LUA_VERSION="5.1.5"

function echoerr() { echo 1>&2;echo "**** $@ ****" 1>&2;echo 1>&2; }
export -f echoerr

function download {
    if [ ! -f $1 ]; then
        echo downloading $1
        curl -s -S -f -O  ${S3_BASE}/$1
    else
        echo using cached $1
    fi
}
export -f download

function upload {
    s3cmd --acl-public put $1 s3://mapnik/deps/
}
export -f upload

function push {
    echo "downloading $1"
    cd ${PACKAGES}
    wget $1
    echo "uploading `basename $1`"
    upload `basename $1`
    cd ${ROOTDIR}
}
export -f push

function check_and_clear_libs {
  if [ $UNAME = 'Darwin' ]; then
        if [ -n "$(find ${BUILD}/lib/ -maxdepth 1 -name '*.a' -print -quit)" ];then
           lipo -info ${BUILD}/lib/*.a | grep arch
        fi
        if [ -n "$(find ${BUILD}/lib/ -maxdepth 1 -name '*.dylib' -print -quit)" ];then
           otool -L ${BUILD}/lib/*.dylib | grep /usr/lib
        fi
    fi
    rm -f ${BUILD}/lib/{*.so,*.dylib}
}
export -f check_and_clear_libs

function ensure_s3cmd {
  if [ ! -d ${PACKAGES}/s3cmd-1.5.0-beta1 ]; then
      CUR_DIR=`pwd`
      wget https://github.com/s3tools/s3cmd/archive/v1.5.0-beta1.tar.gz
      tar xf v1.5.0-beta1.tar.gz
      cd s3cmd-1.5.0-beta1
      export PATH=`pwd`:$PATH
      cd $CUR_DIR
  fi
  if [ ! -f ~/.s3cfg ]; then
    echo "[default]" > ~/.s3cfg
    echo "access_key = $AWS_S3_KEY" >> ~/.s3cfg
    echo "secret_key = $AWS_S3_SECRET" >> ~/.s3cfg
  fi

}
export -f ensure_s3cmd
