#!/usr/bin/env bash

set -u

# settings
export OFFICIAL_RELEASE=false
export USE_BOOST_TRUNK='false'
export SHARED_ZLIB=true

# start from here
export ROOTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

export UNAME=$(uname -s);
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:${PATH}"

# lowercase platform name
export platform_lowercase=$(echo ${MASON_PLATFORM}| sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/")

export DARWIN_VERSION=$(uname -r)
export LIBCXX_DEFAULT=false
if [[ ${UNAME} == 'Darwin' ]]; then
  SEMVER_PATTERN='[^0-9]*\([0-9]*\)[.]\([0-9]*\)[.]\([0-9]*\)\([0-9A-Za-z-]*\)'
  DARWIN_MAJOR=$(echo $DARWIN_VERSION | sed -e "s#$SEMVER_PATTERN#\1#")
  if [[ ${DARWIN_MAJOR} == "13" ]]; then
    export LIBCXX_DEFAULT=true
  fi
fi

export USE_LTO=false
if [[ ${LTO:-false} != false ]]; then
    USE_LTO=true
    # assist cairo configure
    export ax_cv_c_float_words_bigendian=no
fi

export BOOST_TOOLSET="gcc"
if [[ ${UNAME} == 'Darwin' ]]; then
  export BOOST_TOOLSET="clang"
fi

if [[ "${CXX11}" = true ]]; then
  export CXX_STANDARD="cpp11"
else
  export CXX_STANDARD="cpp03"
fi

function echoerr() { echo 1>&2;echo "**** $@ ****" 1>&2;echo 1>&2; }
export -f echoerr

function nprocs() {
    # number of processors on the current system
    case "${UNAME}" in
        'Linux')    nproc;;
        'Darwin')   sysctl -n hw.ncpu;;
        *)          echo 1;;
    esac
}
export -f nprocs

export JOBS=$(nprocs)

function set_dl_path {
    case "${UNAME}" in
        'Linux')    export LD_LIBRARY_PATH="$1";;
        'Darwin')   export DYLD_LIBRARY_PATH="$1";;
        *)          echo 1;;
    esac
}
export -f set_dl_path

function unset_dl_path {
    case "${UNAME}" in
        'Linux')    unset LD_LIBRARY_PATH;;
        'Darwin')   unset DYLD_LIBRARY_PATH;;
        *)          echo 1;;
    esac
}
export -f unset_dl_path

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
export SYSTEM_CURL="/usr/bin/curl"

if [[ "${CXX:-false}" == false ]]; then
    export CXX=
fi

if [[ ${MASON_PLATFORM} == 'Linux' ]]; then
    export EXTRA_CFLAGS="-fPIC"
    if [[ "${CXX11}" == true ]]; then
        if [[ "${CXX#*'clang'}" != "$CXX" ]]; then
            # workaround http://llvm.org/bugs/show_bug.cgi?id=13530#c3
            export EXTRA_CFLAGS="${EXTRA_CFLAGS} -D__float128=void"
        fi
    fi
    export EXTRA_CPPFLAGS=""
    export EXTRA_CXXFLAGS="${EXTRA_CFLAGS}"
    # TODO -Wl,--gc-sections / -Wl,--exclude-libs=ALL / Bsymbolic
    # Note: stripping with -Wl,-S breaks dtrace
    #export EXTRA_LDFLAGS="-Wl,--as-needed"
    # http://www.bnikolic.co.uk/blog/gnu-ld-as-needed.html
    # breaks boost
    #export EXTRA_LDFLAGS="-Wl,--no-undefined -Wl,--no-allow-shlib-undefined"
    export EXTRA_LDFLAGS=""

    if [[ "${CXX:-false}" != false ]] && [[ "${CXX#*'clang'}" != "$CXX" ]]; then
      echoerr "using clang"
      export CORE_CC="clang"
      export CORE_CXX="clang++"
    else
      echoerr "falling back to gcc"
      if [[ "${CXX11}" == true ]]; then
          export CORE_CC="gcc-4.8"
          export CORE_CXX="g++-4.8"
      else
          export CORE_CC="gcc"
          export CORE_CXX="g++"
      fi
    fi
    if [[ ${USE_LTO} == true ]]; then
        echo 'ar "$@" --plugin /usr/lib/LLVMgold.so' > ar-lto
        chmod +x ./ar-lto
        export AR=$(pwd)/ar-lto
        export RANLIB=/bin/true
    else
        export AR=ar
        export RANLIB=ranlib
    fi
    export ARCH_FLAGS=
    # breaking icu symbols?
    #export CXX_VISIBILITY_FLAGS="-fvisibility-inlines-hidden"
    export CXX_VISIBILITY_FLAGS=""
    if [[ "${CXX11}" == true ]]; then
      export STDLIB="libstdcpp"
      export STDLIB_CXXFLAGS="-std=c++11"
      export STDLIB_LDFLAGS=""
    else
      export STDLIB="libstdcpp"
      export STDLIB_CXXFLAGS=""
      export STDLIB_LDFLAGS=""
    fi
elif [[ ${MASON_PLATFORM} == 'Linaro' ]]; then
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
    export EXTRA_CPPFLAGS="--sysroot ${SDK_PATH}"
    export EXTRA_CXXFLAGS="${EXTRA_CFLAGS}"
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
elif [[ ${MASON_PLATFORM} == 'Linaro-softfp' ]]; then
    export ICU_EXTRA_CPP_FLAGS="${ICU_EXTRA_CPP_FLAGS} -DU_HAVE_NL_LANGINFO_CODESET=0"
    cd ${ROOTDIR}
    # NOTE --sysroot used here instead of -isysroot because I assume the former works better on linux
    export EXTRA_CFLAGS="-fPIC --sysroot ${SYSROOT}"
    export EXTRA_LDFLAGS="-Wl,-search_paths_first"
    export EXTRA_CXXFLAGS="${EXTRA_CFLAGS}"
    export EXTRA_CPPFLAGS="--sysroot ${SYSROOT}"
    export PATH="${SDK_PATH}/bin":${PATH}
    export CORE_CXX="arm-linux-gnueabi-g++"
    export CORE_CC="arm-linux-gnueabi-gcc"
    export LD="arm-linux-gnueabi-ld"
    export AR="arm-linux-gnueabi-ar"
    export ARCH_FLAGS=
    export RANLIB="arm-linux-gnueabi-ranlib"
    export NM="arm-linux-gnueabi-nm"
    export STDLIB="libstdcpp"
    export STDLIB_CXXFLAGS=""
    export STDLIB_LDFLAGS=""
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
    export ZLIB_PATH="${SYSROOT}/usr"

elif [[ ${MASON_PLATFORM} == 'Android' ]]; then
    export CXX_VISIBILITY_FLAGS=""
    export alias ldconfig=true
    export EXTRA_CPPFLAGS="-D__ANDROID__"
    export CORE_CXXFLAGS=""
    export ANDROID_NDK_VERSION="r10"
    export API_LEVEL="android-L"
    ${ROOTDIR}/scripts/setup-android-ndk.sh
    export NDK_PATH="${PACKAGES}/android-ndk-${ANDROID_NDK_VERSION}"
    export ANDROID_CROSS_COMPILER="arm-linux-androideabi-4.9"
    export PLATFORM_PREFIX="${NDK_PATH}/active-platform/"
    export NDK_PACKAGE_DIR="${NDK_PATH}/package-dir/"
    # NOTE: make-standalone-toolchain.sh --help for options
    if [[ ! -d "${PLATFORM_PREFIX}" ]]; then
        echo "creating android toolchain with ${ANDROID_CROSS_COMPILER}/${API_LEVEL} at ${PLATFORM_PREFIX}"
        # cd here is to workaround https://code.google.com/p/android/issues/detail?id=67690
        CUR_DIR=$(pwd)
        cd "${NDK_PATH}"
        "${NDK_PATH}/build/tools/make-standalone-toolchain.sh"  \
          --toolchain="${ANDROID_CROSS_COMPILER}" \
          --llvm-version=3.4 \
          --package-dir="${NDK_PACKAGE_DIR}" \
          --install-dir="${PLATFORM_PREFIX}" \
          --stl="libcxx" \
          --arch=arm \
          --platform="${API_LEVEL}"
        cd $CUR_DIR
    else
        echo "using ${ANDROID_CROSS_COMPILER}/${API_LEVEL} at ${PLATFORM_PREFIX}"
    fi
    export ICU_EXTRA_CPP_FLAGS="${ICU_EXTRA_CPP_FLAGS} -DU_HAVE_NL_LANGINFO_CODESET=0"
    alias ldd="arm-linux-androideabi-readelf -d "
    export EXTRA_CFLAGS="-fPIC -D_LITTLE_ENDIAN"
    export EXTRA_CXXFLAGS="${EXTRA_CFLAGS}"
    export EXTRA_LDFLAGS=""
    export BOOST_TOOLSET="gcc-arm"
    export SDK_PATH=
    export PATH="${PLATFORM_PREFIX}/bin":${PATH}
    # use clang in order to support std::atomic
    # https://code.google.com/p/android/issues/detail?id=36496
    export CORE_CXX="arm-linux-androideabi-clang++"
    export CORE_CC="arm-linux-androideabi-clang"
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
      export SDK_ROOT="${XCODE_PREFIX}/Platforms/${XCODE_PLATFORM}.platform/Developer"
      # /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer
      export PLATFORM_SDK="${XCODE_PLATFORM}${ACTIVE_SDK_VERSION}.sdk"
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
    export ARCH_FLAGS="-arch ${ARCH_NAME}"
    export PATH=${TOOLCHAIN_ROOT}:$PATH
    export EXTRA_CPPFLAGS=""
    export EXTRA_CXXFLAGS="${EXTRA_CFLAGS}"
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
    echo '**unhandled platform: ${MASON_PLATFORM}**'
fi

export MAPNIK_SOURCE="${ROOTDIR}/mapnik-${CXX_STANDARD}-${STDLIB}"
export BUILDDIR="build-${CXX_STANDARD}-${STDLIB}"
export BUILD_ROOT="${ROOTDIR}/out/${BUILDDIR}"
export BUILD_TOOLS_ROOT="${ROOTDIR}/out/build-tools"
export BUILD="${BUILD_ROOT}-${ARCH_NAME}-${platform_lowercase}"
export MAPNIK_DESTDIR="${BUILD}-mapnik"
export MAPNIK_BIN_SOURCE="${MAPNIK_DESTDIR}${MAPNIK_INSTALL}"
export MAPNIK_CONFIG="${MAPNIK_BIN_SOURCE}/bin/mapnik-config"

export ZLIB_PATH="${BUILD}"
if [[ $SHARED_ZLIB == true ]]; then
    if [[ ${MASON_PLATFORM} = 'Linux' ]]; then
        export ZLIB_PATH="/usr";
    elif [[ ${MASON_PLATFORM} = 'Linaro' ]]; then
        export ZLIB_PATH="/usr";
    elif [[ ${MASON_PLATFORM} = 'Linaro-softfp' ]]; then
        export ZLIB_PATH="/usr";
    else
        if [[ ${MASON_PLATFORM} = 'Android' ]]; then
            # TODO - mavericks: ln -sf $(xcrun --show-sdk-path)/usr/include /usr/include
            export ZLIB_PATH=${PLATFORM_PREFIX};
        else
            if [[ ${SDK_PATH} ]]; then
                export ZLIB_PATH=${SDK_PATH}/usr;
            fi
        fi
    fi
fi

export PKG_CONFIG_PATH="${BUILD}/lib/pkgconfig"
export PATH="${BUILD}/bin:$PATH"
export ARCHFLAGS="${ARCH_FLAGS}"
export CORE_CPPFLAGS=""
export DEBUG_FLAGS="-DNDEBUG"
export CORE_CFLAGS="${DEBUG_FLAGS} -O${OPTIMIZATION} ${ARCH_FLAGS} -D_FILE_OFFSET_BITS=64"
export CORE_CXXFLAGS="${CXX_VISIBILITY_FLAGS} ${CORE_CFLAGS}"
export CORE_LDFLAGS="-O${OPTIMIZATION} ${ARCH_FLAGS}"

if [[ ${CXX:-false} == false ]]; then
    if [[ ${CORE_CXX:-false} != false ]]; then
        export CXX="${CORE_CXX}"
    else
        export CXX="c++"
    fi
fi

if [[ ${CC:-false} == false ]]; then
    if [[ ${CORE_CC:-false} != false ]]; then
        export CC="${CORE_CC}"
    else
        export CC="cc"
    fi
fi

echo "using $CXX version : $(${CXX} -dumpversion)"

export C_INCLUDE_PATH="${BUILD}/include"
export CPLUS_INCLUDE_PATH="${BUILD}/include"
export LIBRARY_PATH="${BUILD}/lib"
export SHARED_LIBRARY_PATH="${LIBRARY_PATH}"
export CPPFLAGS="${CORE_CPPFLAGS} ${EXTRA_CPPFLAGS}"
# silence warnings in C dependencies like cairo, freetype, libxml2, pixman
export WARNING_CFLAGS="-Wno-unknown-warning-option -Wno-long-long -Wno-unused-parameter -Wno-unused-but-set-variable -Wno-strict-prototypes -Wno-unused-variable -Wno-redundant-decls -Wno-return-type -Wno-uninitialized -Wno-unused-result -Wno-format"
# clang specific
if test "${CC#*'clang'}" != "$CC"; then
  export WARNING_CFLAGS="-Wno-invalid-source-encoding -Wno-cast-align -Wno-extended-offsetof ${WARNING_CFLAGS}"
fi
export CFLAGS="-I${BUILD}/include $CORE_CFLAGS $EXTRA_CFLAGS ${WARNING_CFLAGS}"
# we intentially do not silence warnings in cxx apps, we want to see them all
export CXXFLAGS="${STDLIB_CXXFLAGS} -I${BUILD}/include $CORE_CXXFLAGS $EXTRA_CXXFLAGS"
export LDFLAGS="-L${BUILD}/lib $CORE_LDFLAGS $EXTRA_LDFLAGS"

if [[ ${USE_LTO} == true ]]; then
    export CFLAGS="-flto ${CFLAGS}"
    export CXXFLAGS="-flto ${CXXFLAGS}"
    export LDFLAGS="-flto ${LDFLAGS}"
fi

# CMAKE systems ignore LDFLAGS but accept LINK_FLAGS
export LINK_FLAGS=${LDFLAGS}

# tgz
# NOTE: regenerate the .dat with new major versions via
# http://apps.icu-project.org/datacustom/
# include the 'collators' and 'break iterator'
# download it, unzip, rename, check it in, then edit the below paths and versions
export PREMADE_ICU_DATA_LIBRARY="${ROOTDIR}/icudt53l_only_collator_and_breakiterator.dat"
# http://site.icu-project.org/download
export ICU_VERSION="53.1"
export ICU_VERSION2="53_1"
# http://www.boost.org/users/download/
export BOOST_VERSION="1.55.0"
export BOOST_VERSION2="1_55_0"
# http://www.sqlite.org/download.html
export SQLITE_VERSION="3080500"
# http://download.savannah.gnu.org/releases/freetype/freetype-2.5.3.tar.bz2
# http://nongnu.askapache.com/freetype/freetype-2.5.3.tar.bz2
export FREETYPE_VERSION="2.5.3"
# http://download.osgeo.org/proj/
export PROJ_VERSION="4.8.0"
# TODO - test proj-datumgrid-1.6RC1.zip
export PROJ_GRIDS_VERSION="1.5"
# http://www.libpng.org/pub/png/libpng.html
export LIBPNG_VERSION="1.6.12"
# http://download.osgeo.org/libtiff/
export LIBTIFF_VERSION="4.0.3"
# https://code.google.com/p/webp/downloads/list
export WEBP_VERSION="0.4.0"
# http://download.osgeo.org/geotiff/libgeotiff/
export LIBGEOTIFF_VERSION="1.4.0"
export JPEG_VERSION="8d"
export NASM_VERSION="2.11"
# http://sourceforge.net/projects/libjpeg-turbo/files/
export JPEG_TURBO_VERSION="1.3.1"
export EXPAT_VERSION="2.1.0"
# http://download.osgeo.org/gdal/CURRENT/
export GDAL_VERSION="1.11.0"
export GETTEXT_VERSION="0.18.1.1"
# http://ftp.postgresql.org/pub/source/
# gz
export POSTGRES_VERSION="9.3.4"
# http://zlib.net/zlib-1.2.8.tar.gz
export ZLIB_VERSION="1.2.8"
# ftp://xmlsoft.org/libxml2/
export LIBXML2_VERSION="2.9.1"
export BZIP2_VERSION="1.0.6"
export PKG_CONFIG_VERSION="0.25"
# http://www.freedesktop.org/software/fontconfig/release/
# bz2
export FONTCONFIG_VERSION="2.11.1"
# http://cairographics.org/releases/
# gz
export PIXMAN_VERSION="0.32.6"
export CAIRO_VERSION="1.12.16"
export PY2CAIRO_VERSION="1.10.0"
export PY3CAIRO_VERSION="1.10.0"
# http://download.osgeo.org/geos/
export GEOS_VERSION="3.4.2"
export PROTOBUF_VERSION="2.5.0"
export PROTOBUF_C_VERSION="0.15"
export XZ_VERSION="5.0.5"
export NOSE_VERSION="1.2.1"
# stuck at feb 2012
# https://code.google.com/p/sparsehash/source/list
export SPARSEHASH_VERSION="2.0.2"
# http://www.freedesktop.org/software/harfbuzz/release/
# bz2
export HARFBUZZ_VERSION="0.9.35"
export STXXL_VERSION="1.4.0"
export LUABIND_VERSION="0.9.1"
export LUA_VERSION="5.1.5"
export LIBLAS_VERSION="1.7.0"
export CURL_VERSION="7.36.0"
# http://www.openssl.org/source/
export OPENSSL_VERSION="1.0.1i"
export LIBUV_VERSION="0.11.28"
export NODE_VERSION="0.10.30"

function download {
    if [[ ! -f $1 ]]; then
        echoerr "downloading $1"
        ${SYSTEM_CURL} -s -S -f -O -L --retry 3 ${S3_BASE}/$1
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
    ${SYSTEM_CURL} -s -S -f -O -L $1
    echo "uploading $(basename $1)"
    upload $(basename $1)
    cd ${ROOTDIR}
}
export -f push

function check_and_clear_libs {
  mkdir -p "${SHARED_LIBRARY_PATH}"
  if [[ ${UNAME} == 'Darwin' ]]; then
        #for i in $(find ${BUILD}/lib/ -maxdepth 1 -name '*.a' -print); do
        #   lipo -info $i | grep arch 1>&2;
        #done;
        for i in $(find ${BUILD}/lib/ -maxdepth 1 -name '*.dylib' -print); do
           otool -L ${i} 1>&2;
        done;
        #for i in $(find ${BUILD}/lib/ -maxdepth 1 -name '*.dylib' -print); do
        #    mv ${i} "${BUILD}/lib/_shared/"
        #done;
  else
      for i in $(find ${BUILD}/lib/ -maxdepth 1 -name '*.so*' -print); do
         ldd ${i} 1>&2
      done
      #for i in $(find ${BUILD}/lib/ -maxdepth 1 -name '*.so*' -print); do
      #    mv ${i} "${BUILD}/lib/_shared/$(basename ${i})"
      #done
  fi
}
export -f check_and_clear_libs

function ensure_s3cmd {
  CUR_DIR=$(pwd)
  mkdir -p ${PACKAGES}/
  if [[ ! -d ${PACKAGES}/s3cmd-1.5.0-beta1 ]]; then
      cd ${PACKAGES}
      ${SYSTEM_CURL} -s -S -f -O -L https://github.com/s3tools/s3cmd/archive/v1.5.0-beta1.tar.gz
      tar xf v1.5.0-beta1.tar.gz
  fi
  cd ${PACKAGES}/s3cmd-1.5.0-beta1
  export PATH=$(pwd):${PATH}
  cd $CUR_DIR
  if [[ ! -f ~/.s3cfg ]]; then
    if [[ "${AWS_ACCESS_KEY_ID:-false}" == false ]] || [[ "${AWS_SECRET_ACCESS_KEY:-false}" == false ]]; then
        echoerr 'missing AWS keys: see ensure_s3cmd in settings.sh for details'
    else
        echo "[default]" > ~/.s3cfg
        echo "access_key = $AWS_ACCESS_KEY_ID" >> ~/.s3cfg
        echo "secret_key = $AWS_SECRET_ACCESS_KEY" >> ~/.s3cfg
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
      rm -rf xz-${XZ_VERSION}
      tar xf xz-${XZ_VERSION}.tar.bz2
      cd xz-${XZ_VERSION}
      OLD_PLATFORM=${MASON_PLATFORM}
      source "${ROOTDIR}/${HOST_PLATFORM}.sh"
      ./configure --prefix=${BUILD_TOOLS_ROOT}
      make -j${JOBS}
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
      OLD_PLATFORM=${MASON_PLATFORM}
      source "${ROOTDIR}/${HOST_PLATFORM}.sh"
      ./configure --prefix=${BUILD_TOOLS_ROOT}
      make -j${JOBS}
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
  if [[ ${MASON_PLATFORM} == 'Linux' ]]; then
      # http://llvm.org/releases/3.4/clang+llvm-3.4-x86_64-linux-gnu-ubuntu-13.10.tar.xz
      if [[ ! -f clang+llvm-$CVER-Ubuntu-13.04-x86_64-linux-gnu.tar.bz2 ]]; then
          echoerr 'downloading clang'
          ${SYSTEM_CURL} -s -S -f -O -L http://llvm.org/releases/$CVER/clang+llvm-$CVER-Ubuntu-13.04-x86_64-linux-gnu.tar.bz2
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
          ${SYSTEM_CURL} -s -S -f -O -L http://llvm.org/releases/$CVER/clang+llvm-$CVER-x86_64-apple-darwin$DARWIN_V.tar.gz
      fi
      if [[ ! -d clang+llvm-$CVER-x86_64-apple-darwin$DARWIN_V ]] && [[ ! -d clang-$CVER ]]; then
          echoerr 'uncompressing clang'
          tar xf clang+llvm-$CVER-x86_64-apple-darwin$DARWIN_V.tar.gz
          mv clang+llvm-$CVER-x86_64-apple-darwin$DARWIN_V clang-$CVER
      fi
  fi
  echoerr "enabled clang at $(pwd)/clang-$CVER/bin"
  export PATH=$(pwd)/clang-$CVER/bin:$PATH
  cd $CUR_DIR
}
export -f ensure_clang

function memsize() {
    # total physical memory in MB
    case "${UNAME}" in
        'Linux')    echo $(($(free | awk '/^Mem:/{print $2}')/1024));;
        'Darwin')   echo $(($(sysctl -n hw.memsize)/1024/1024));;
        *)          echo 1;;
    esac
}
export -f memsize

echoerr "building against ${STDLIB} in ${CXX_STANDARD} mode with ${CXX}"

set +u

