
# set clean PATH
export PATH="/usr/bin:/bin:/usr/sbin:/sbin"

export ROOTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# NOTE: supporting 10.6 on OS X 10.8 requires copying old 10.6 SDK into:
# /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/
export MIN_SDK_VERSION="10.7"

XCODE_PREFIX=$( xcode-select -print-path )
#if [[ $XCODE_PREFIX == "/Developer" ]]; then
if [[ -d /Applications/Xcode.app/Contents/Developer ]]; then
    export XCODE_PREFIX="/Applications/Xcode.app/Contents/Developer"
    export CORE_CXX="/usr/bin/clang++"
    export CORE_CC="/usr/bin/clang"
    # /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer
    export SDK_PATH="${XCODE_PREFIX}/Platforms/MacOSX.platform/Developer/SDKs/MacOSX${MIN_SDK_VERSION}.sdk" ## >= 4.3.1 from MAC
    # search for 'auxiliary' at https://developer.apple.com/downloads/index.action
    # http://adcdownload.apple.com/Developer_Tools/auxiliary_tools_for_xcode__february_2012/auxiliary_tools_for_xcode.dmg
    export PATH="/Applications/PackageMaker.app/Contents/MacOS:${PATH}"
else
    export SDK_PATH="${XCODE_PREFIX}/SDKs/MacOSX${MIN_SDK_VERSION}.sdk" ## Xcode 4.2
    #export PATH="/Developer/usr/bin:${PATH}"
    export CORE_CXX="/opt/llvm/bin/clang++"
    export CORE_CC="/opt/llvm/bin/clang"
fi

# needed for Coda.app terminal to act sanely
# otherwise various tests fail oddly
#export LANG=en_US.UTF-8

# settings
#export MAPNIK_INSTALL=/opt/mapnik
export MAPNIK_INSTALL="/Library/Frameworks/Mapnik.framework/unix"
export MAPNIK_SOURCE="${ROOTDIR}/mapnik"
export PATH=${MAPNIK_SOURCE}/utils/mapnik-config:${PATH}
export MAPNIK_DIST="${ROOTDIR}/dist"
export PACKAGES="${ROOTDIR}/packages"
export BUILD="${ROOTDIR}/build"
export MAPNIK_PACKAGE_PREFIX="mapnik"
# cd ${MAPNIK_SOURCE}
# MAPNIK_HASH=`git reflog show HEAD | sed -n '1p' | awk '{ print $1 }'`
export MAPNIK_DEV_POSTFIX=""

export OPTIMIZATION="3"
export JOBS=`sysctl -n hw.ncpu`
if [[ $JOBS > 4 ]]; then
    export JOBS=$(expr $JOBS - 2)
fi
# -arch i386 breaks icu Collator::createInstance
export ARCH_FLAGS="-arch x86_64"
#export ARCH_FLAGS="-arch x86_64 -arch i386"
export ARCHFLAGS=${ARCH_FLAGS}
export CORE_CPPFLAGS=""
export CORE_CFLAGS="-O${OPTIMIZATION} ${ARCH_FLAGS} -D_FILE_OFFSET_BITS=64"
export CORE_CXXFLAGS=${CORE_CFLAGS}
export CORE_LDFLAGS="-O${OPTIMIZATION} ${ARCH_FLAGS} -Wl,-search_paths_first -headerpad_max_install_names"

# breaks distutils
#export MACOSX_DEPLOYMENT_TARGET=${MIN_SDK_VERSION}
#export OSX_SDK_CFLAGS="-mmacosx-version-min=${MIN_SDK_VERSION} -isysroot ${SDK_PATH}"
#export OSX_SDK_LDFLAGS="-mmacosx-version-min=${MIN_SDK_VERSION} -isysroot ${SDK_PATH}"
#export OSX_SDK_LDFLAGS="-mmacosx-version-min=${MIN_SDK_VERSION} -Wl,-syslibroot,${SDK_PATH}"
export OSX_SDK_CFLAGS=""
export OSX_SDK_LDFLAGS=""
export OSX_SDK_LDFLAGS=""
export CXX=${CORE_CXX}
export CC=${CORE_CC}
export CPPFLAGS=${CORE_CPPFLAGS}
export LDFLAGS="-L${BUILD}/lib $CORE_LDFLAGS $OSX_SDK_LDFLAGS"
export CFLAGS="-I${BUILD}/include $CORE_CFLAGS $OSX_SDK_CFLAGS"
export CXXFLAGS="-I${BUILD}/include $CORE_CXXFLAGS $OSX_SDK_CFLAGS"

export DYLD_LIBRARY_PATH="${BUILD}/lib"
export PKG_CONFIG_PATH="${BUILD}/lib/pkgconfig"
export PATH="${BUILD}/bin:$PATH"

# versions
export ICU_VERSION="50.1.2"
export ICU_VERSION2="50_1_2"
export BOOST_VERSION="1.53.0"
export BOOST_VERSION2="1_53_0"
export SQLITE_VERSION="3071502"
export FREETYPE_VERSION="2.4.11"
export PROJ_VERSION="4.8.0"
export PROJ_GRIDS_VERSION="1.5"
export LIBPNG_VERSION="1.5.14"
export LIBTIFF_VERSION="4.0.3"
export LIBGEOTIFF_VERSION="1.4.0"
export JPEG_VERSION="8d"
export EXPAT_VERSION="2.1.0"
export GDAL_VERSION="1.9.2"
export GETTEXT_VERSION="0.18.1.1"
export POSTGRES_VERSION="9.2.3"
export ZLIB_VERSION="1.2.7"
export LIBTOOL_VERSION="2.4.2"
export LIBXML2_VERSION="2.9.0"
export BZIP2_VERSION="1.0.6"

# cairo stuff
export PKG_CONFIG_VERSION="0.25"
export FONTCONFIG_VERSION="2.10.0"
export PIXMAN_VERSION="0.28.2"
export CAIRO_VERSION="1.12.14"
export PY2CAIRO_VERSION="1.10.0"
export PY3CAIRO_VERSION="1.10.0"

