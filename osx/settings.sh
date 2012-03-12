export ROOTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# needed for Coda.app terminal to act sanely
# otherwise various tests fail oddly
#export LANG=en_US.UTF-8

# settings
#export MAPNIK_INSTALL=/opt/mapnik
export MAPNIK_INSTALL=/Library/Frameworks/Mapnik.framework/unix
export MAPNIK_SOURCE=${ROOTDIR}/mapnik
export MAPNIK_DIST=${ROOTDIR}/dist
export PACKAGES=${ROOTDIR}/packages
export BUILD=${ROOTDIR}/build
export MAPNIK_TAR_DIR="mapnik"
export OPTIMIZATION="-Os"
export JOBS="`sysctl -n hw.ncpu`"
# -arch i386 breaks icu Collator::createInstance
export ARCH_FLAGS="-arch x86_64"
#export ARCH_FLAGS="-arch x86_64 -arch i386"
export ARCHFLAGS=${ARCH_FLAGS}
export CORE_CXX="/Developer/usr/bin/clang++"
export CORE_CC="/Developer/usr/bin/clang"
export CXX=${CORE_CXX}
export CC=${CORE_CC}
export CPPFLAGS="-DU_CHARSET_IS_UTF8=1" # to reduce icu library size (18.3)
export CORE_CFLAGS="${OPTIMIZATION} ${ARCH_FLAGS}"
export CORE_CXXFLAGS=${CORE_CFLAGS}
export CORE_LDFLAGS="${OPTIMIZATION} ${ARCH_FLAGS} -Wl,-search_paths_first -headerpad_max_install_names"
# breaks distutils
#export MACOSX_DEPLOYMENT_TARGET=10.6
export OSX_SDK_CFLAGS="-mmacosx-version-min=10.6 -isysroot /Developer/SDKs/MacOSX10.6.sdk"
export OSX_SDK_LDFLAGS="-mmacosx-version-min=10.6 -isysroot /Developer/SDKs/MacOSX10.6.sdk"
#export OSX_SDK_LDFLAGS="-mmacosx-version-min=10.6 -Wl,-syslibroot,/Developer/SDKs/MacOSX10.6.sdk"
export CFLAGS=$CORE_CFLAGS
export CXXFLAGS=$CORE_CXXFLAGS
export LDFLAGS=$CORE_LDFLAGS

# boost regex link:
# -licui18n -licudata -licuuc    -headerpad_max_install_names -Wl,-dead_strip -no_dead_strip_inits_and_terms -isysroot /Developer/SDKs/MacOSX10.6.sdk -arch i386 -arch x86_64

export DYLD_LIBRARY_PATH="${BUILD}/lib"
export PKG_CONFIG_PATH="${BUILD}/lib/pkgconfig"
export PATH="${BUILD}/bin:$PATH"

# versions
export ICU_VERSION="4.8.1.1"
export ICU_VERSION2="4_8_1_1"
export ICU_MAJOR_VER="48"
export BOOST_VERSION="1.48.0"
export BOOST_VERSION2="1_48_0"
export SQLITE_VERSION="3070900"
export FREETYPE_VERSION="2.4.8"
export PROJ_GRIDS_VERSION="1.5"
export CAIRO_VERSION="1.10.2"
export CAIROMM_VERSION="1.10.0"
export SIGCPP_VERSION="2.2"
export SIGCPP_VERSION2="2.2.10"
export LIBPNG_VERSION="1.5.6"
export LIBTIFF_VERSION="3.9.5"
export JPEG_VERSION="8c"
export GDAL_VERSION="1.8.1"
export PIXMAN_VERSION="0.22.2"
export GETTEXT_VERSION="0.18.1.1"
export PKG_CONFIG_VERSION="0.25"
export FONTCONFIG_VERSION="2.8.0"
export POSTGRES_VERSION="9.1.2"
