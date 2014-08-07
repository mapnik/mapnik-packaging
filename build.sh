#!/bin/bash

UNAME=$(uname -s)

function b {
  if [[ "${QUIET:-false}" != false ]]; then
    $1 1>> build.log
  else
    $1
  fi
}

function setup {
  set -e
}

function teardown {
  set +e
}

function prep_osx {
  cd osx
  if [[ "${PLATFORM:-false}" != false ]]; then
      source ${PLATFORM}.sh
  else
      source MacOSX.sh
  fi
  brew install autoconf automake libtool makedepend cmake | true
  export PATH=$(brew --prefix)/bin:$PATH
  mkdir -p ${BUILD}
  mkdir -p ${BUILD}/lib
  mkdir -p ${BUILD}/include
}

function upgrade_gcc {
    echo "adding gcc-4.8 ppa"
    sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
    echo "updating apt"
    sudo apt-get update -qq -y
    echo "installing C++11 compiler"
    sudo apt-get install -qq -y gcc-4.8 g++-4.8
    export CORE_CC="gcc-4.8"
    export CORE_CXX="g++-4.8"
    export CC="${CORE_CC}"
    export CXX="${CORE_CXX}"
    export CXX_NAME="gcc-4.8"
}

function upgrade_clang {
    echo "adding clang + gcc-4.8 ppa"
    sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
    wget -O - http://llvm.org/apt/llvm-snapshot.gpg.key|sudo apt-key add -
    sudo apt-get install clang-3.4
    echo "updating apt"
    sudo apt-get update -qq -y
    echo "installing C++11 compiler"
    sudo apt-get install -y libstdc++6 libstdc++-4.8-dev
    if [[ ! -f /usr/lib/LLVMgold.so ]]; then
        sudo ln -s /usr/lib/llvm-3.4/lib/LLVMgold.so /usr/lib/LLVMgold.so
    fi
    if [[ ! -f /usr/lib/libLTO.so ]]; then
      sudo ln -s /usr/lib/llvm-3.4/lib/libLTO.so /usr/lib/libLTO.so
    fi
    sudo apt-get install binutils-gold
    export CORE_CC="/usr/bin/clang"
    export CORE_CXX="/usr/bin/clang++"
    export CC="${CORE_CC}"
    export CXX="${CORE_CXX}"
    export CXX_NAME="clang-3.4"
}

function prep_linux {
  cd osx
  if [[ "${PLATFORM:-false}" != false ]]; then
      source ${PLATFORM}.sh
  else
      source Linux.sh
  fi
  #if [[ "${CXX11}" == true ]]; then
    upgrade_clang
  #else
  #  echo "updating apt"
  #  sudo apt-get update -y -qq
  #fi;
  echo "installing build tools"
  sudo apt-get install -qq -y build-essential git cmake zlib1g-dev unzip make libtool autotools-dev automake autoconf
  mkdir -p ${BUILD}
  mkdir -p ${BUILD}/lib
  mkdir -p ${BUILD}/include
}

function basic_prep {
  if [[ $UNAME == 'Linux' ]]; then
      prep_linux
      sudo apt-get install -qq -y subversion
  else
      prep_osx
  fi
  echo "Running build with ${JOBS} parallel jobs"
}


: '
Actual apps. We setup and teardown when building these
so that the set -e and PATH does not break the parent
environment in odd ways if this script is sourced
'

function build_mapnik {
  setup
  if [[ $UNAME == 'Linux' ]]; then
      prep_linux
      sudo apt-get install -qq -y python-dev python-nose
      # postgres deps
      # https://github.com/mapnik/mapnik-packaging/commit/598db68f4e5314883023eb6048e94ba7c021b6b7
      #sudo apt-get install -qq -y libpam0g-dev libgss-dev libkrb5-dev libldap2-dev libavahi-compat-libdnssd-dev
      echo "removing potentially conflicting libraries"
      # remove travis default installed libs which will conflict
      sudo apt-get purge -qq -y libtiff* libjpeg* libpng3
      sudo apt-get autoremove -y -qq
  else
      prep_osx
  fi
  echo "checking cpu and mem resources"
  nprocs
  memsize
  echo "Running build with ${JOBS} parallel jobs"
  # NOTE: harfbuzz needs pkg-config to find icu
  b ./scripts/build_pkg_config.sh
  b ./scripts/build_icu.sh
  BOOST_LIBRARIES="--with-thread --with-filesystem --disable-filesystem2 --with-system --with-regex"
  if [ ${BOOST_ARCH} != "arm" ]; then
      BOOST_LIBRARIES="$BOOST_LIBRARIES --with-program_options"
      # --with-chrono --with-iostreams --with-date_time --with-atomic --with-timer --with-program_options --with-test
  fi
  ./scripts/build_boost.sh ${BOOST_LIBRARIES}
  b ./scripts/build_freetype.sh
  b ./scripts/build_harfbuzz.sh
  b ./scripts/build_libxml2.sh
  b ./scripts/build_jpeg_turbo.sh
  b ./scripts/build_png.sh
  b ./scripts/build_proj4.sh
  #./scripts/build_geotiff.sh
  # for mapnik-vector-tile
  b ./scripts/build_protobuf.sh
  if [[ ${BOOST_ARCH} != "arm" ]]; then
    b ./scripts/build_python_versions.sh
    if [[ "${MINIMAL_MAPNIK:-false}" == false ]]; then
      b ./scripts/build_webp.sh
      b ./scripts/build_tiff.sh
      b ./scripts/build_sqlite.sh
      b ./scripts/build_expat.sh
      b ./scripts/build_postgres.sh
      b ./scripts/build_gdal.sh
      b ./scripts/build_pixman.sh
      b ./scripts/build_fontconfig.sh
      b ./scripts/build_cairo.sh
      b ./scripts/build_pycairo.sh
    fi
  fi
  branch="master"
  if [[ "${CXX11}" == false ]]; then
      branch="2.3.x"
  fi
  if [ ! -d ${MAPNIK_SOURCE} ]; then
      git clone --quiet https://github.com/mapnik/mapnik.git ${MAPNIK_SOURCE} -b $branch
      git branch -v
  fi
  if [[ "${CXX11}" == false ]]; then
      cd ${MAPNIK_SOURCE}
      git checkout $branch
      git pull
      git branch -v
      cd ../
  fi
  ./scripts/build_mapnik.sh
  ./scripts/post_build_fix.sh
  ./scripts/test_mapnik.sh
  ./scripts/package_mobile_sdk.sh
  teardown
}

function build_osrm {
  setup
  basic_prep
  if [[ $UNAME == 'Linux' ]]; then
      upgrade_gcc
  fi
  b ./scripts/build_tbb.sh
  b ./scripts/build_libxml2.sh
  b ./scripts/build_lua.sh
  b ./scripts/build_zlib.sh
  b ./scripts/build_bzip2.sh
  # TODO: osrm boost usage does not need icu
  ./scripts/build_boost.sh --with-test --with-iostreams --with-date_time --with-program_options --with-thread --with-filesystem --disable-filesystem2 --with-system --with-regex
  b ./scripts/build_protobuf.sh
  b ./scripts/build_osm-pbf.sh
  b ./scripts/build_luabind.sh
  b ./scripts/build_libstxxl.sh
  ./scripts/build_osrm.sh
  teardown
}

export -f build_osrm

function build_osmium {
  setup
  basic_prep
  b ./scripts/build_expat.sh
  b ./scripts/build_google_sparsetable.sh
  # TODO: osrm boost usage does not need icu
  ./scripts/build_boost.sh --with-test --with-program_options
  b ./scripts/build_protobuf.sh
  b ./scripts/build_osm-pbf.sh
  b ./scripts/build_cryptopp.sh
  teardown
}

export -f build_osmium

function mobile_tools {
  setup
  basic_prep
  sudo apt-get install -qq -y xutils-dev # for gccmakedep used in openssl
  b ./scripts/build_zlib.sh
  b ./scripts/build_libuv.sh
  b ./scripts/build_openssl.sh
  b ./scripts/build_curl.sh
  b ./scripts/build_protobuf.sh
  b ./scripts/build_google_sparsetable.sh
  b ./scripts/build_freetype.sh
  b ./scripts/build_harfbuzz.sh
  b ./scripts/build_libxml2.sh
  b ./scripts/build_jpeg_turbo.sh
  b ./scripts/build_png.sh
  b ./scripts/build_webp.sh
  b ./scripts/build_tiff.sh
  b ./scripts/build_sqlite.sh
  ./scripts/build_boost.sh --with-regex
  teardown
}
export -f mobile_tools

function build_http {
  setup
  basic_prep
  sudo apt-get install -qq -y xutils-dev # for gccmakedep used in openssl
  b ./scripts/build_zlib.sh
  b ./scripts/build_libuv.sh
  b ./scripts/build_openssl.sh
  b ./scripts/build_curl.sh
  ./scripts/build_boost.sh --with-regex
  b ./scripts/build_glfw.sh
  teardown
}
export -f build_http

function build_osm2pgsql {
  setup
  basic_prep
  b ./scripts/build_bzip2.sh
  b ./scripts/build_geos.sh
  b ./scripts/build_proj4.sh
  b ./scripts/build_postgres.sh
  b ./scripts/build_protobuf.sh
  b ./scripts/build_protobuf_c.sh
  teardown
}
export -f build_osm2pgsql

function build_liblas {
  setup
  basic_prep
  b ./scripts/build_zlib.sh
  b ./scripts/build_jpeg_turbo.sh
  b ./scripts/build_png.sh
  b ./scripts/build_tiff.sh
  b ./scripts/build_proj4.sh
  b ./scripts/build_geotiff.sh
  b ./scripts/build_geos.sh
  b ./scripts/build_sqlite.sh
  b ./scripts/build_spatialite.sh
  b ./scripts/build_expat.sh
  b ./scripts/build_postgres.sh
  b ./scripts/build_gdal.sh
  b ./scripts/build_laszip.sh
  ./scripts/build_boost.sh --with-thread --with-program_options
  b ./scripts/build_liblas.sh
  teardown
}
export -f build_liblas
