#!/bin/bash

set -u

# settings
export OFFICIAL_RELEASE=false
export USE_BOOST_TRUNK='false'
export SHARED_ZLIB=true

# start from here
export ROOTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

export UNAME=$(uname -s);
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:${PATH}"

export DARWIN_VERSION=$(uname -r)
export LIBCXX_DEFAULT=false
if [[ ${UNAME} == 'Darwin' ]]; then
  SEMVER_PATTERN='[^0-9]*\([0-9]*\)[.]\([0-9]*\)[.]\([0-9]*\)\([0-9A-Za-z-]*\)'
  DARWIN_MAJOR=$(echo $DARWIN_VERSION | sed -e "s#$SEMVER_PATTERN#\1#")
  if [[ ${DARWIN_MAJOR} == "13" ]]; then
    export LIBCXX_DEFAULT=true
  fi
fi

if [[ "${CXX11}" = true ]]; then
  export CXX_STANDARD="cpp11"
else
  export CXX_STANDARD="cpp03"
fi


# lowercase platform name
export platform=$(echo $PLATFORM | sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/")

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

if [[ ${PLATFORM} == 'Linux' ]]; then
    export EXTRA_CFLAGS="-fPIC"
    if [[ "${CXX11}" == true ]]; then
        if [[ "${CXX:-false}" == "clang++" ]]; then
            # workaround http://llvm.org/bugs/show_bug.cgi?id=13530#c3
            export EXTRA_CFLAGS="${EXTRA_CFLAGS} -D__float128=void"
        fi
    fi
    export EXTRA_CXXFLAGS="${EXTRA_CFLAGS}"
    # TODO -Wl,--gc-sections / -Wl,--exclude-libs=ALL / Bsymbolic
    # Note: stripping with -Wl,-S breaks dtrace
    #export EXTRA_LDFLAGS="-Wl,--as-needed"
    # http://www.bnikolic.co.uk/blog/gnu-ld-as-needed.html
    # breaks boost
    #export EXTRA_LDFLAGS="-Wl,--no-undefined -Wl,--no-allow-shlib-undefined"
    export EXTRA_LDFLAGS=""
    if [[ "${CXX:-false}" == "clang++" ]]; then
      export CORE_CC="clang"
      export CORE_CXX="clang++"
      if [[ "${CXX_NAME:-false}" == false ]]; then
          # TODO - use -dumpversion
          export CXX_NAME="clang-3.3"
      fi
    else
      if [[ "${CXX11}" == true ]]; then
          export CORE_CC="gcc-4.8"
          export CORE_CXX="g++-4.8"
          export CXX_NAME="gcc-4.8"
      else
          export CORE_CC="gcc"
          export CORE_CXX="g++"
          export CXX_NAME="gcc-4.6"
      fi
    fi
    export AR=ar
    export RANLIB=ranlib
    export ARCH_FLAGS=
    export JOBS=$(grep -c ^processor /proc/cpuinfo)
    export BOOST_TOOLSET="gcc"
    # breaking icu symbols?
    #export CXX_VISIBILITY_FLAGS="-fvisibility-inlines-hidden"
    export CXX_VISIBILITY_FLAGS=""
    if [[ "${CXX11}" == true ]]; then
      export STDLIB="libstdcpp"
      export STDLIB_CXXFLAGS="-std=c++11 -DBOOST_SPIRIT_USE_PHOENIX_V3=1"
      export STDLIB_LDFLAGS=""
    else
      export STDLIB="libstdcpp"
      export STDLIB_CXXFLAGS=""
      export STDLIB_LDFLAGS=""
    fi
elif [[ ${PLATFORM} == 'Linaro' ]]; then
    export UNAME='Linaro'
    export ICU_EXTRA_CPP_FLAGS="${ICU_EXTRA_CPP_FLAGS} -DU_HAVE_NL_LANGINFO_CODESET=0"
    export SDK_PATH="${PACKAGES}/linaro-prebuilt-sysroot-2013.07-2"
    cd ${PACKAGES}
    # https://launchpad.net/linaro-toolchain-binaries/support/01/+download/linaro-prebuilt-sysroot-2013.07-2.tar.bz2
    download linaro-prebuilt-sysroot-2013.07-2.tar.bz2
    if [[ ! -d ${SDK_PATH} ]]; then
        echo "untarring ${SDK_PATH}"
        tar -xf linaro-prebuilt-sysroot-2013.07-2.tar.bz2
    fi
    cd ${ROOTDIR}
    # NOTE --sysroot used here instead of -isysroot because I assume the former works better on linux
    export EXTRA_CFLAGS="-fPIC --sysroot ${SDK_PATH}"
    export EXTRA_LDFLAGS="--sysroot ${SDK_PATH} -Wl,-search_paths_first"
    export EXTRA_CXXFLAGS="${EXTRA_CFLAGS}"
    export JOBS=$(sysctl -n hw.ncpu)
    export BOOST_TOOLSET="gcc-arm"
    export PATH="${SDK_PATH}/bin":${PATH}
    export CORE_CXX="arm-linux-gnueabihf-g++"
    export CORE_CC="arm-linux-gnueabihf-gcc"
    export LD="arm-linux-gnueabihf-ld"
    export AR="arm-linux-gnueabihf-ar"
    export ARCH_FLAGS=
    export RANLIB="arm-linux-gnueabihf-ranlib"
    export NM="arm-linux-gnueabihf-nm"
    export STDLIB="libstdcpp"
    export STDLIB_CXXFLAGS=""
    export STDLIB_LDFLAGS=""
elif [[ ${PLATFORM} == 'Android' ]]; then
    export UNAME='Android'
    export API_LEVEL="android-18"
    export ANDROID_CROSS_COMPILER="arm-linux-androideabi-4.8"
    # run ./scripts/setup-android-ndk-adk-osx.sh to setup
    export NDK_PATH="${PACKAGES}/android-ndk-r9"
    #ln -s ../android/android-ndk-r9 ./android-ndk-r9
    export PLATFORM_PREFIX="${NDK_PATH}/active-platform/"
    # NOTE: make-standalone-toolchain.sh --help for options
    if [[ ! -d "${PLATFORM_PREFIX}" ]]; then
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
    export JOBS=$(sysctl -n hw.ncpu)
    export BOOST_TOOLSET="gcc-arm"
    export SDK_PATH=
    export PATH="${PLATFORM_PREFIX}/bin":${PATH}
    export CORE_CXX="arm-linux-androideabi-g++"
    export CORE_CC="arm-linux-androideabi-gcc"
    if [[ "${CXX_NAME:-false}" == false ]]; then
        # TODO
        export CXX_NAME="gcc-4.6"
    fi
    export LD="arm-linux-androideabi-ld"
    export AR="arm-linux-androideabi-ar"
    export ARCH_FLAGS=
    export RANLIB="arm-linux-androideabi-ranlib"
    # TODO - some builds hardcode libtool which breaks since os x version is used (zlib)
    #alias libtool="arm-linux-androideabi-ar cru"
    #export libtool="arm-linux-androideabi-ar cru"
    export NM="arm-linux-androideabi-nm"
    export STDLIB="libstdcpp"
    export STDLIB_CXXFLAGS=""
    export STDLIB_LDFLAGS=""
elif [[ ${UNAME} == 'Darwin' ]]; then
    # NOTE: supporting 10.6 on OS X 10.8 requires copying old 10.6 SDK into:
    # /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/
    XCODE_CMD="xcode-select"
    export XCODE_PREFIX=$(${XCODE_CMD} -print-path)
    if [[ -d "${XCODE_PREFIX}/Toolchains/" ]]; then
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
      export EXTRA_LDFLAGS="${MIN_SDK_VERSION_FLAG} -isysroot ${SDK_PATH} -L${SDK_PATH}/usr/lib -Wl,-search_paths_first"
    else
      export TOOLCHAIN_ROOT="${XCODE_PREFIX}/usr/bin"
      export SDK_PATH="${XCODE_PREFIX}/usr/"
      export CORE_CC="${TOOLCHAIN_ROOT}/clang"
      export CORE_CXX="${TOOLCHAIN_ROOT}/clang++"
      export EXTRA_CFLAGS=""
      # todo -no_dead_strip_inits_and_terms
      export EXTRA_LDFLAGS="-Wl,-search_paths_first"
    fi
    if [[ "${CXX_NAME:-false}" == false ]]; then
        # TODO
        export CXX_NAME="clang-3.3"
    fi
    export ARCH_FLAGS="-arch ${ARCH_NAME}"
    export PATH=${TOOLCHAIN_ROOT}:$PATH
    export EXTRA_CXXFLAGS="${EXTRA_CFLAGS}"
    export JOBS=$(sysctl -n hw.ncpu)
    export BOOST_TOOLSET="clang"
    # warning this breaks some c++ linking, like v8 mksnapshot since it then links as C
    # and needs to default to 'gyp-mac-tool'
    #export LD="clang"
    unset LD
    unset AR
    unset RANLIB
    # breaks node.js -fvisibility=hidden and partially breaks gdal bin programs
    export CXX_VISIBILITY_FLAGS="-fvisibility-inlines-hidden"
    if [[ "${CXX11}" == true ]]; then
        export STDLIB="libcpp"
        export STDLIB_CXXFLAGS="-std=c++11 -stdlib=libc++"
        export STDLIB_LDFLAGS="-stdlib=libc++" #-lc++ -lc++abi
    else
        export STDLIB="libstdcpp"
        export STDLIB_CXXFLAGS="-Wno-c++11-long-long -stdlib=libstdc++"
        export STDLIB_LDFLAGS="-stdlib=libstdc++"
    fi
else
    echo '**unhandled platform: ${PLATFORM}**'
fi

export MAPNIK_SOURCE="${ROOTDIR}/mapnik-${CXX_STANDARD}-${STDLIB}"
export BUILDDIR="build-${CXX_STANDARD}-${STDLIB}"
export BUILD_UNIVERSAL="${ROOTDIR}/out/${BUILDDIR}-universal"
export BUILD_ROOT="${ROOTDIR}/out/${BUILDDIR}"
export BUILD_TOOLS_ROOT="${ROOTDIR}/out/build-tools"
export BUILD="${BUILD_ROOT}-${ARCH_NAME}"
export MAPNIK_DESTDIR="${BUILD}-mapnik"
export MAPNIK_BIN_SOURCE="${MAPNIK_DESTDIR}${MAPNIK_INSTALL}"
export MAPNIK_CONFIG="${MAPNIK_BIN_SOURCE}/bin/mapnik-config"

export ZLIB_PATH="${BUILD}"
if [[ $SHARED_ZLIB == true ]]; then
    if [[ ${PLATFORM} = 'Linux' ]]; then
        export ZLIB_PATH="/usr";
    else
        if [[ ${PLATFORM} = 'Android' ]]; then
            # TODO - mavericks: ln -sf $(xcrun --show-sdk-path)/usr/include /usr/include
            export ZLIB_PATH=$PLATFORM_PREFIX;
        else
            if [[ ${SDK_PATH} ]]; then
                export ZLIB_PATH=${SDK_PATH}/usr;
            fi
        fi
    fi
fi

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
# silence warnings in C depedencies like cairo, freetype, libxml2, pixman
export WARNING_CFLAGS="-Wno-long-long -Wno-unused-variable -Wno-redundant-decls -Wno-uninitialized -Wno-unused-result -Wno-format"
# clang specific
if test "${CC#*'clang'}" != "$CC"; then
  export WARNING_CFLAGS="-Wno-invalid-source-encoding -Wno-unused-parameter -Wno-cast-align -Wno-extended-offsetof ${WARNING_CFLAGS}"
fi
export CFLAGS="-I${BUILD}/include $CORE_CFLAGS $EXTRA_CFLAGS ${WARNING_CFLAGS}"
# we intentially do not silence warnings in cxx apps, we want to see them all
export CXXFLAGS="${STDLIB_CXXFLAGS} -I${BUILD}/include $CORE_CXXFLAGS $EXTRA_CXXFLAGS"

# http://site.icu-project.org/download
# tgz
# NOTE: regenerate the .dat with new major versions via
# http://apps.icu-project.org/datacustom/
# include the 'collators' and 'break iterator'
# download it, unzip, rename, check it in, then edit the below paths and versions
export PREMADE_ICU_DATA_LIBRARY="${ROOTDIR}/icudt53l_only_collator_and_breakiterator.dat"
export ICU_VERSION="53.1"
export ICU_VERSION2="53_1"
# http://www.boost.org/users/download/
export BOOST_VERSION="1.55.0"
export BOOST_VERSION2="1_55_0"
# http://www.sqlite.org/download.html
export SQLITE_VERSION="3080402"
# http://download.savannah.gnu.org/releases/freetype/freetype-2.5.3.tar.bz2
# http://nongnu.askapache.com/freetype/freetype-2.5.3.tar.bz2
export FREETYPE_VERSION="2.5.3"
# http://download.osgeo.org/proj/
export PROJ_VERSION="4.8.0"
# TODO - test proj-datumgrid-1.6RC1.zip
export PROJ_GRIDS_VERSION="1.5"
# http://www.libpng.org/pub/png/libpng.html
export LIBPNG_VERSION="1.6.10"
# http://download.osgeo.org/libtiff/
export LIBTIFF_VERSION="4.0.3"
# https://code.google.com/p/webp/downloads/list
export WEBP_VERSION="0.4.0"
# http://download.osgeo.org/geotiff/libgeotiff/
export LIBGEOTIFF_VERSION="1.4.0"
export JPEG_VERSION="8d"
export NASM_VERSION="2.11"
export JPEG_TURBO_VERSION="1.3.1"
export EXPAT_VERSION="2.1.0"
# http://download.osgeo.org/gdal/CURRENT/
export GDAL_VERSION="1.10.1"
export GETTEXT_VERSION="0.18.1.1"
# http://ftp.postgresql.org/pub/source/
# gz
export POSTGRES_VERSION="9.3.3"
# http://zlib.net/zlib-1.2.8.tar.gz
export ZLIB_VERSION="1.2.8"
# ftp://xmlsoft.org/libxml2/
export LIBXML2_VERSION="2.9.1"
export BZIP2_VERSION="1.0.6"
export PKG_CONFIG_VERSION="0.25"
# http://www.freedesktop.org/software/fontconfig/release/
# bz2
export FONTCONFIG_VERSION="2.11.0"
# http://cairographics.org/releases/
export PIXMAN_VERSION="0.32.4"
export CAIRO_VERSION="1.12.16"
export PY2CAIRO_VERSION="1.10.0"
export PY3CAIRO_VERSION="1.10.0"
# http://download.osgeo.org/geos/
export GEOS_VERSION="3.4.2"
export PROTOBUF_VERSION="2.5.0"
export PROTOBUF_C_VERSION="0.15"
export XZ_VERSION="5.0.3"
export NOSE_VERSION="1.2.1"
export NODE_VERSION="0.10.26"
export SPARSEHASH_VERSION="2.0.2"
# http://www.freedesktop.org/software/harfbuzz/release/
# bz2
# export HARFBUZZ_VERSION="0.9.19"
export HARFBUZZ_VERSION="0.9.27"
export STXXL_VERSION="1.4.0"
export LUABIND_VERSION="0.9.1"
export LUA_VERSION="5.1.5"
export LIBLAS_VERSION="1.7.0"
export CURL_VERSION="7.36.0"
# http://www.openssl.org/source/
export OPENSSL_VERSION="1.0.1g"
export LIBUV_VERSION="0.11.23"

function echoerr() { echo 1>&2;echo "**** $@ ****" 1>&2;echo 1>&2; }
export -f echoerr

function download {
    if [[ ! -f $1 ]]; then
        echoerr "downloading $1"
        curl -s -S -f -O -L ${S3_BASE}/$1
    else
        echoerr "using cached $1"
    fi
}
export -f download

function upload {
    ensure_s3cmd
    s3cmd --acl-public put $1 s3://mapnik/deps/
}
export -f upload

function push {
    echo "downloading $1"
    cd ${PACKAGES}
    curl -s -S -f -O -L $1
    echo "uploading $(basename $1)"
    upload $(basename $1)
    cd ${ROOTDIR}
}
export -f push

function check_and_clear_libs {
  if [[ $UNAME == 'Darwin' ]]; then
        for i in $(find ${BUILD}/lib/ -maxdepth 1 -name '*.a' -print); do
           lipo -info $i | grep arch 1>&2;
        done;
        for i in $(find ${BUILD}/lib/ -maxdepth 1 -name '*.dylib' -print); do
           otool -L ${i} 1>&2;
        done;
    else
        for i in $(find ${BUILD}/lib/ -maxdepth 1 -name '*.so*' -print); do
           ldd ${i} 1>&2
        done
    fi
    rm -f ${BUILD}/lib/{*.so*,*.dylib}
}
export -f check_and_clear_libs

function ensure_s3cmd {
  CUR_DIR=$(pwd)
  if [[ ! -d ${PACKAGES}/s3cmd-1.5.0-beta1 ]]; then
      cd ${PACKAGES}
      curl -s -S -f -O -L https://github.com/s3tools/s3cmd/archive/v1.5.0-beta1.tar.gz
      tar xf v1.5.0-beta1.tar.gz
  fi
  cd ${PACKAGES}/s3cmd-1.5.0-beta1
  export PATH=$(pwd):${PATH}
  cd $CUR_DIR
  if [[ ! -f ~/.s3cfg ]]; then
    if [[ "${AWS_S3_KEY:-false}" == false ]] || [[ "${AWS_S3_SECRET:-false}" == false ]]; then
        echoerr 'missing AWS keys: see ensure_s3cmd in settings.sh for details'
    else
        echo "[default]" > ~/.s3cfg
        echo "access_key = $AWS_S3_KEY" >> ~/.s3cfg
        echo "secret_key = $AWS_S3_SECRET" >> ~/.s3cfg
    fi
  fi
}
export -f ensure_s3cmd

function ensure_xz {
  if [[ ! -f ${BUILD_TOOLS_ROOT}/bin/xz ]]; then
      CUR_DIR=$(pwd)
      mkdir -p ${PACKAGES}
      cd ${PACKAGES}
      # WARNING: this installs liblzma which we need to ensure that gdal does not link to
      download xz-${XZ_VERSION}.tar.bz2
      echoerr '*building xz*'
      rm -rf xz-5.0.3
      tar xf xz-5.0.3.tar.bz2
      cd xz-5.0.3
      OLD_PLATFORM=${PLATFORM}
      source "${ROOTDIR}/${HOST_PLATFORM}.sh"
      ./configure --prefix=${BUILD_TOOLS_ROOT}
      make -j$JOBS
      make install
      source "${ROOTDIR}/${OLD_PLATFORM}.sh"
      cd $CUR_DIR
  fi
  export PATH=${BUILD_TOOLS_ROOT}/bin:$PATH
}
export -f ensure_xz

function ensure_nasm {
  if [[ ! -f ${BUILD_TOOLS_ROOT}/bin/nasm ]]; then
      CUR_DIR=$(pwd)
      mkdir -p ${PACKAGES}
      cd ${PACKAGES}
      # WARNING: this installs liblzma which we need to ensure that gdal does not link to
      download nasm-${NASM_VERSION}.tar.bz2
      echoerr '*building nasm*'
      rm -rf nasm-${NASM_VERSION}
      tar xf nasm-${NASM_VERSION}.tar.bz2
      cd nasm-${NASM_VERSION}
      OLD_PLATFORM=${PLATFORM}
      source "${ROOTDIR}/${HOST_PLATFORM}.sh"
      ./configure --prefix=${BUILD_TOOLS_ROOT}
      make -j$JOBS
      make install install_rdf
      source "${ROOTDIR}/${OLD_PLATFORM}.sh"
      cd $CUR_DIR
  fi
  export PATH=${BUILD_TOOLS_ROOT}/bin:$PATH
}
export -f ensure_nasm


function ensure_clang {
  CVER="3.3"
  if [[ ! -z $1 ]]; then
    CVER=$1
  fi
  CUR_DIR=$(pwd)
  mkdir -p ${PACKAGES}
  cd ${PACKAGES}
  if [[ ${PLATFORM} == 'Linux' ]]; then
      # http://llvm.org/releases/3.4/clang+llvm-3.4-x86_64-linux-gnu-ubuntu-13.10.tar.xz
      if [[ ! -f clang+llvm-$CVER-Ubuntu-13.04-x86_64-linux-gnu.tar.bz2 ]]; then
          echoerr 'downloading clang'
          curl -s -S -f -O -L http://llvm.org/releases/$CVER/clang+llvm-$CVER-Ubuntu-13.04-x86_64-linux-gnu.tar.bz2
      fi
      if [[ ! -d clang+llvm-$CVER-Ubuntu-13.04-x86_64-linux-gnu ]] && [[ ! -d clang-$CVER ]]; then
          echoerr 'uncompressing clang'
          tar xf clang+llvm-$CVER-Ubuntu-13.04-x86_64-linux-gnu.tar.bz2
          mv clang+llvm-$CVER-Ubuntu-13.04-x86_64-linux-gnu clang-$CVER
      fi
  else
      if [[ $CVER == "3.4" ]]; then
          DARWIN_V="10.9"
      fi
      if [[ $CVER == "3.3" ]]; then
          DARWIN_V="12"
      fi
      if [[ $CVER == "3.2" ]]; then
          DARWIN_V="11"
      fi
      if [[ ! -f clang+llvm-$CVER-x86_64-apple-darwin$DARWIN_V.tar.gz ]]; then
          echoerr 'downloading clang'
          curl -s -S -f -O -L http://llvm.org/releases/$CVER/clang+llvm-$CVER-x86_64-apple-darwin$DARWIN_V.tar.gz
      fi
      if [[ ! -d clang+llvm-$CVER-x86_64-apple-darwin$DARWIN_V ]] && [[ ! -d clang-$CVER ]]; then
          echoerr 'uncompressing clang'
          tar xf clang+llvm-$CVER-x86_64-apple-darwin$DARWIN_V.tar.gz
          mv clang+llvm-$CVER-x86_64-apple-darwin$DARWIN_V clang-$CVER
      fi
  fi
  echoerr "enabled clang at $(pwd)/clang-$CVER/bin"
  export PATH=$(pwd)/clang-$CVER/bin:$PATH
  export CXX_NAME="clang-$CVER"
  cd $CUR_DIR
}
export -f ensure_clang

function memsize() {
    # total physical memory in MB
    case "$(uname -s)" in
        'Linux')    echo $(($(free | awk '/^Mem:/{print $2}')/1024));;
        'Darwin')   echo $(($(sysctl -n hw.memsize)/1024/1024));;
        *)          echo 1;;
    esac
}
export -f memsize

function nprocs() {
    # number of processors on the current system
    case "$(uname -s)" in
        'Linux')    nproc;;
        'Darwin')   sysctl -n hw.ncpu;;
        *)          echo 1;;
    esac
}
export -f nprocs

echoerr "building against ${STDLIB} in ${CXX_STANDARD} mode with ${CXX}"

set +u

