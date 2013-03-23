
# start from here
export ROOTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# set clean PATH
export PATH="/usr/bin:/bin:/usr/sbin:/sbin"

# NOTE: supporting 10.6 on OS X 10.8 requires copying old 10.6 SDK into:
# /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/

# Target Platform
export PLATFORM="MacOSX"
export MIN_SDK_VERSION="10.7"
export HOST_ARG=""
export ARCH_NAME="x86_64"
export BOOST_ARCH="x86"
export MIN_SDK_VERSION_FLAG="-mmacosx-version-min=${MIN_SDK_VERSION}"
#export MACOSX_DEPLOYMENT_TARGET=${MIN_SDK_VERSION} # breaks distutils

# iphone
# -pipe -no-cpp-precomp

# armv7 device
: '
export MIN_SDK_VERSION="5.1" # 6.1
export MIN_SDK_VERSION_FLAG="-miphoneos-version-min=2.2"

export PLATFORM="iPhoneOS"
export ARCH_NAME="armv7"
export BOOST_ARCH="arm"
export HOST_ARG="--host=arm-apple-darwin"

# simulator
export PLATFORM="iPhoneSimulator"
export ARCH_NAME="i386"
export BOOST_ARCH="x86"
export HOST_ARG="--host=i686-apple-darwin11"
'

export XCODE_PREFIX=$( xcode-select -print-path )
export ARCH_FLAGS="-arch ${ARCH_NAME}"
# set this up with:
#   sudo xcode-select -switch /Applications/Xcode.app/Contents/Developer
# for more info
#   man xcrun
export CORE_CC="${XCODE_PREFIX}/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang"
export CORE_CXX="${XCODE_PREFIX}/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang++"
export SDK_ROOT="${XCODE_PREFIX}/Platforms/${PLATFORM}.platform/Developer"
# /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer
export PLATFORM_SDK="${PLATFORM}${MIN_SDK_VERSION}.sdk"
export SDK_PATH="${SDK_ROOT}/SDKs/${PLATFORM_SDK}" ## >= 4.3.1 from MAC
# search for 'auxiliary' at https://developer.apple.com/downloads/index.action
# http://adcdownload.apple.com/Developer_Tools/auxiliary_tools_for_xcode__february_2012/auxiliary_tools_for_xcode.dmg
export PATH="/Applications/PackageMaker.app/Contents/MacOS:${PATH}"

# needed for Coda.app terminal to act sanely
# otherwise various tests fail oddly
#export LANG=en_US.UTF-8

# settings
export MAPNIK_INSTALL="/Library/Frameworks/Mapnik.framework/unix"
export MAPNIK_SOURCE="${ROOTDIR}/mapnik"
export PATH=${MAPNIK_SOURCE}/utils/mapnik-config:${PATH}
export MAPNIK_DIST="${ROOTDIR}/dist"
export PACKAGES="${ROOTDIR}/packages"
export BUILD="${ROOTDIR}/build-${ARCH_NAME}"
export MAPNIK_PACKAGE_PREFIX="mapnik"
export MAPNIK_DEV_POSTFIX=""

export OPTIMIZATION="3"
export JOBS=`sysctl -n hw.ncpu`
if [[ $JOBS > 4 ]]; then
    export JOBS=$(expr $JOBS - 2)
fi
export ARCHFLAGS=${ARCH_FLAGS}
export CORE_CPPFLAGS=""
export CORE_CFLAGS="-O${OPTIMIZATION} ${ARCH_FLAGS} -D_FILE_OFFSET_BITS=64"
export CORE_CXXFLAGS=${CORE_CFLAGS}
export CORE_LDFLAGS="-O${OPTIMIZATION} ${ARCH_FLAGS} -Wl,-search_paths_first -headerpad_max_install_names -Wl,-dead_strip"

export CXX=${CORE_CXX}
export CC=${CORE_CC}
export CPPFLAGS=${CORE_CPPFLAGS}
export OSX_SDK_CFLAGS="${MIN_SDK_VERSION_FLAG} -isysroot ${SDK_PATH}"
export OSX_SDK_LDFLAGS="${MIN_SDK_VERSION_FLAG} -isysroot ${SDK_PATH}"
export LDFLAGS="-L${BUILD}/lib $CORE_LDFLAGS $OSX_SDK_LDFLAGS"
export CFLAGS="-I${BUILD}/include $CORE_CFLAGS $OSX_SDK_CFLAGS"
export CXXFLAGS="-I${BUILD}/include $CORE_CXXFLAGS $OSX_SDK_CFLAGS"

export DYLD_LIBRARY_PATH="${BUILD}/lib"
export PKG_CONFIG_PATH="${BUILD}/lib/pkgconfig"
export PATH="${BUILD}/bin:$PATH"
