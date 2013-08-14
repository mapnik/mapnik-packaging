# settings
export CXX11='true'
export OFFICIAL_RELEASE='false'
export USE_BOOST_TRUNK='false'

# start from here
export ROOTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# set clean PATH
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin"

export UNAME=$(uname -s);

# note: -DUCONFIG_NO_BREAK_ITERATION=1 is desired by mapnik (for toTitle)
# http://www.icu-project.org/apiref/icu4c/uconfig_8h_source.html
export ICU_CORE_CPP_FLAGS="-DU_CHARSET_IS_UTF8=1 -DU_USING_ICU_NAMESPACE=0 -DU_STATIC_IMPLEMENTATION=1 -DU_TIMEZONE=0 -DUCONFIG_NO_LEGACY_CONVERSION=1 -DUCONFIG_NO_FORMATTING=1 -DUCONFIG_NO_TRANSLITERATION=1 -DUCONFIG_NO_REGULAR_EXPRESSIONS=1"
export ICU_EXTRA_CPP_FLAGS="${ICU_CORE_CPP_FLAGS} -DUCONFIG_NO_COLLATION=1"

export PREMADE_ICU_DATA_LIBRARY="${ROOTDIR}/icudt51l.dat"

if [ ${PLATFORM} = 'Linux' ]; then
    export EXTRA_CFLAGS="-fPIC"
    export EXTRA_CXXFLAGS="${EXTRA_CFLAGS}"
    export EXTRA_LDFLAGS="-Wl,-S"
    export CORE_CC="gcc"
    export CORE_CXX="g++"
    export AR=
    export RANLIB=
    export ARCH_FLAGS=
    export JOBS=`grep -c ^processor /proc/cpuinfo`
    export BOOST_TOOLSET="gcc"
    export CXX_VISIBILITY_FLAGS="-fvisibility-inlines-hidden"
    if [ $CXX11 = 'true' ]; then
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
    # http://dl.google.com/android/ndk/android-ndk-r9-darwin-x86.tar.bz2
    export NDK_PATH="${ROOTDIR}/android-ndk-r9"
    #ln -s ../android/android-ndk-r9 ./android-ndk-r9
    export PLATFORM_PREFIX="${ROOTDIR}/platform/"
    export API_LEVEL="android-18"
    if [ ! -d "${PLATFORM_PREFIX}" ]; then
        "${NDK_PATH}/build/tools/make-standalone-toolchain.sh"  \
          --toolchain=arm-linux-androideabi-4.6 \
          --install-dir="${PLATFORM_PREFIX}" \
          --stl=gnustl \
          --arch=arm \
          --platform="${API_LEVEL}"
    fi
    export ICU_EXTRA_CPP_FLAGS="${ICU_EXTRA_CPP_FLAGS} -DU_HAVE_NL_LANGINFO_CODESET=0"
    alias ldd="arm-linux-androideabi-readelf -d "
    export EXTRA_CFLAGS="-fPIC -D_LITTLE_ENDIAN"
    export EXTRA_CXXFLAGS="${EXTRA_CFLAGS}"
    export EXTRA_LDFLAGS="-Wl,-S"
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
    XCODE_PREFIX=$( xcode-select -print-path )
    export ARCH_FLAGS="-arch ${ARCH_NAME}"
    # set this up with:
    #   sudo xcode-select -switch /Applications/Xcode.app/Contents/Developer
    # for more info
    #   man xcrun
    export TOOLCHAIN_ROOT="${XCODE_PREFIX}/Toolchains/XcodeDefault.xctoolchain/usr/bin"
    export PATH=${TOOLCHAIN_ROOT}:$PATH
    export CORE_CC="${TOOLCHAIN_ROOT}/clang"
    export CORE_CXX="${XCODE_PREFIX}/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang++"
    export AR=
    export RANLIB=
    export SDK_ROOT="${XCODE_PREFIX}/Platforms/${PLATFORM}.platform/Developer"
    # /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer
    export PLATFORM_SDK="${PLATFORM}${MIN_SDK_VERSION}.sdk"
    export SDK_PATH="${SDK_ROOT}/SDKs/${PLATFORM_SDK}" ## >= 4.3.1 from MAC
    export EXTRA_CFLAGS="${MIN_SDK_VERSION_FLAG} -isysroot ${SDK_PATH}"
    export EXTRA_CXXFLAGS="${EXTRA_CFLAGS}"
    export EXTRA_LDFLAGS="${MIN_SDK_VERSION_FLAG} -isysroot ${SDK_PATH} -Wl,-search_paths_first -Wl,-S"
    export JOBS=`sysctl -n hw.ncpu`
    export BOOST_TOOLSET="clang"
    export LD="clang"
    # breaks node.js -fvisibility=hidden and partially breaks gdal bin programs
    export CXX_VISIBILITY_FLAGS="-fvisibility-inlines-hidden"
    if [ $CXX11 = 'true' ]; then
        export STDLIB="libc++"
        export STDLIB_CXXFLAGS="-std=c++11 -stdlib=libc++"
        export STDLIB_LDFLAGS="-stdlib=libc++" #-lc++ -lc++abi
        echo "building against libc++ in c++11 mode"
    else
      echo "building against libstdc++"
      export STDLIB="libstdc++"
      export STDLIB_CXXFLAGS=""
      export STDLIB_LDFLAGS=""
    fi
else
    echo '**unhandled platform: ${PLATFORM}**'
fi

export BUILDDIR="build-${STDLIB}"
export BUILD_UNIVERSAL="${ROOTDIR}/out/${BUILDDIR}-universal"
export OPTIMIZATION="3"
export S3_BASE="http://mapnik.s3.amazonaws.com/deps"
export BUILD_ROOT="${ROOTDIR}/out/${BUILDDIR}"
export BUILD="${BUILD_ROOT}-${ARCH_NAME}"
export MAPNIK_DIST="${ROOTDIR}/out/dist"
export PACKAGES="${ROOTDIR}/out/packages"
export PATCHES="${ROOTDIR}/patches"
export STAGING="${ROOTDIR}/out/staging"
export MAPNIK_SOURCE="${ROOTDIR}/mapnik"
export MAPNIK_DESTDIR="${BUILD}-mapnik"
export MAPNIK_INSTALL="/usr/local"
export MAPNIK_BIN_SOURCE="${MAPNIK_DESTDIR}${MAPNIK_INSTALL}"
export PATH="${MAPNIK_BIN_SOURCE}/bin:${MAPNIK_SOURCE}/utils/mapnik-config:${PATH}"
export MAPNIK_PACKAGE_PREFIX="mapnik"

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
export CFLAGS="-I${BUILD}/include $CORE_CFLAGS $EXTRA_CFLAGS"
export CXXFLAGS="${STDLIB_CXXFLAGS} -I${BUILD}/include $CORE_CXXFLAGS $EXTRA_CXXFLAGS"

# http://site.icu-project.org/download
export ICU_VERSION="51.2"
export ICU_VERSION2="51_2"

export BOOST_VERSION="1.53.0"
export BOOST_VERSION2="1_53_0"
# http://www.sqlite.org/download.html
export SQLITE_VERSION="3071700"
# http://download.savannah.gnu.org/releases/freetype/
export FREETYPE_VERSION="2.4.12"
# http://download.osgeo.org/proj/
export PROJ_VERSION="4.8.0"
# TODO - test proj-datumgrid-1.6RC1.zip
export PROJ_GRIDS_VERSION="1.5"
# http://www.libpng.org/pub/png/libpng.html
export LIBPNG_VERSION="1.6.2"
# http://download.osgeo.org/libtiff/
export LIBTIFF_VERSION="4.0.3"
#https://code.google.com/p/webp/downloads/
export WEBP_VERSION="0.3.1"
# http://download.osgeo.org/geotiff/libgeotiff/
export LIBGEOTIFF_VERSION="1.4.0"
export JPEG_VERSION="8d"
export EXPAT_VERSION="2.1.0"
# http://download.osgeo.org/gdal/CURRENT/
export GDAL_VERSION="1.10.0"
export GETTEXT_VERSION="0.18.1.1"
# http://ftp.postgresql.org/pub/source/
export POSTGRES_VERSION="9.2.4"
# http://zlib.net/zlib-1.2.8.tar.gz
export ZLIB_VERSION="1.2.8"
# ftp://xmlsoft.org/libxml2/
export LIBXML2_VERSION="2.9.1"
export BZIP2_VERSION="1.0.6"
export PKG_CONFIG_VERSION="0.25"
export FONTCONFIG_VERSION="2.10.0"
# http://cairographics.org/releases/
export PIXMAN_VERSION="0.30.0"
export CAIRO_VERSION="1.12.14"
export PY2CAIRO_VERSION="1.10.0"
export PY3CAIRO_VERSION="1.10.0"
# http://download.osgeo.org/geos/
export GEOS_VERSION="3.3.8"
export PROTOBUF_VERSION="2.5.0"
export PROTOBUF_C_VERSION="0.15"
export XZ_VERSION="5.0.3"
export NOSE_VERSION="1.2.1"
export NODE_VERSION="0.10.15"

