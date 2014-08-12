#!/bin/bash

UNAME=$(uname -s)

# http://nothingworks.donaitken.com/2012/04/returning-booleans-from-bash-functions
function is_set {
    # usage:
    # is_set $variable
    local R=0; # 0=true
    if [[ "${1:-unset_val}" == "unset_val" ]]; then
        R=1 # false
    fi
    return $R;
}

function contains {
    # usage:
    # contains substring fullstring
    local R=0; # 0=true
    if [[ "${2#*$1}" == $2 ]]; then
        R=1 # false
    fi
    return $R;
}

function eq {
    # usage:
    # eq $var1 value
    local R=0; # 0=true
    if [[ "${1}" != $2 ]]; then
        R=1 # false
    fi
    return $R;
}

function b {
  if eq $QUIET true; then
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
}

function upgrade_clang {
    echo "adding clang + gcc-4.8 ppa"
    sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
    if [[ `lsb_release --release | cut -f2` != "14.04" ]]; then
        sudo add-apt-repository 'deb http://llvm.org/apt/precise/ llvm-toolchain-precise-3.5 main'
    fi
    wget -O - http://llvm.org/apt/llvm-snapshot.gpg.key|sudo apt-key add -
    echo "updating apt"
    sudo apt-get update -y -qq
    CLANG_VERSION="3.4"
    echo "installing clang-${CLANG_VERSION}"
    apt-cache policy clang-${CLANG_VERSION}
    sudo apt-get install -y clang-${CLANG_VERSION}
    echo "installing C++11 compiler"
    if [[ `lsb_release --release | cut -f2` != "14.04" ]]; then
        echo 'upgrading libstdc++'
        sudo apt-get install -y libstdc++6 libstdc++-4.8-dev
    fi
    if [[ ${LTO:-false} != false ]]; then
        echo "upgrading binutils-gold"
        sudo apt-get install -y -qq binutils-gold
        if [[ ! -h "/usr/lib/LLVMgold.so" ]] && [[ ! -f "/usr/lib/LLVMgold.so" ]]; then
            echo "symlinking /usr/lib/llvm-${CLANG_VERSION}/lib/LLVMgold.so"
            sudo ln -s /usr/lib/llvm-${CLANG_VERSION}/lib/LLVMgold.so /usr/lib/LLVMgold.so
        fi
        if [[ ! -h "/usr/lib/libLTO.so" ]] && [[ ! -f "/usr/lib/libLTO.so" ]]; then
            echo "symlinking /usr/lib/llvm-${CLANG_VERSION}/lib/libLTO.so"
            sudo ln -s /usr/lib/llvm-${CLANG_VERSION}/lib/libLTO.so /usr/lib/libLTO.so
        fi
        # TODO - needed on trusty for pkg-config
        # since 'binutils-gold' on trusty does not switch
        # /usr/bin/ld to point to /usr/bin/ld.gold like it does
        # in the precise package
        #sudo rm /usr/bin/ld
        #sudo ln -s /usr/bin/ld.gold /usr/bin/ld
    fi
    # for bjam since it can't find a custom named clang-3.4
    if [[ ! -h "/usr/bin/clang" ]] && [[ ! -f "/usr/bin/clang" ]]; then
        echo "symlinking /usr/bin/clang-${CLANG_VERSION}"
        sudo ln -s /usr/bin/clang-${CLANG_VERSION} /usr/bin/clang
    fi
    if [[ ! -h "/usr/bin/clang++" ]] && [[ ! -f "/usr/bin/clang++" ]]; then
        echo "symlinking /usr/bin/clang++-${CLANG_VERSION}"
        sudo ln -s /usr/bin/clang++-${CLANG_VERSION} /usr/bin/clang++
    fi
    # prefer upgraded clang
    if [[ -f "/usr/bin/clang++-${CLANG_VERSION}" ]]; then
        export CORE_CC="/usr/bin/clang-${CLANG_VERSION}"
        export CORE_CXX="/usr/bin/clang++-${CLANG_VERSION}"
    else
        export CORE_CC="/usr/bin/clang"
        export CORE_CXX="/usr/bin/clang++"
    fi
    export CC="${CORE_CC}"
    export CXX="${CORE_CXX}"
}

function upgrade_compiler {
    if [[ ${UNAME} == 'Linux' ]]; then
        # if CXX is set, detect if clang
        # otherwise fallback to gcc
        if is_set ${CXX}; then
            if contains 'clang' ${CXX}; then
                upgrade_clang
            else
                upgrade_gcc
            fi
        else
            upgrade_gcc
        fi
    fi
}

function prep_linux {
  cd osx
  if [[ "${PLATFORM:-false}" != false ]]; then
      source ${PLATFORM}.sh
  else
      source Linux.sh
  fi
  echo "installing build tools"
  sudo apt-get install -qq -y build-essential git cmake zlib1g-dev unzip make libtool autotools-dev automake autoconf
}

function prep_osx {
  cd osx
  if [[ "${PLATFORM:-false}" != false ]]; then
      source ${PLATFORM}.sh
  else
      source MacOSX.sh
  fi
  brew install autoconf automake libtool makedepend cmake || true
  export PATH=$(brew --prefix)/bin:$PATH
}

function prepare_os {
  if [[ ${UNAME} == 'Linux' ]]; then
      prep_linux
      sudo apt-get install -qq -y subversion
  else
      prep_osx
  fi
  mkdir -p ${BUILD}
  mkdir -p ${BUILD}/lib
  mkdir -p ${BUILD}/include
  echo "Running build with ${JOBS} parallel jobs"
  echo "checking cpu and mem resources"
  nprocs
  memsize
}


: '
Actual apps. We setup and teardown when building these
so that the set -e and PATH does not break the parent
environment in odd ways if this script is sourced
'

function build_mapnik {
  setup
  upgrade_compiler
  prepare_os
  if [[ ${UNAME} == 'Linux' ]]; then
      sudo apt-get install -qq -y python-dev python-nose
      # postgres deps
      # https://github.com/mapnik/mapnik-packaging/commit/598db68f4e5314883023eb6048e94ba7c021b6b7
      #sudo apt-get install -qq -y libpam0g-dev libgss-dev libkrb5-dev libldap2-dev libavahi-compat-libdnssd-dev
      echo "removing potentially conflicting libraries"
      # remove travis default installed libs which will conflict
      sudo apt-get purge -qq -y libtiff* libjpeg* libpng3
      sudo apt-get autoremove -y -qq
  fi
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
  b ./scripts/build_webp.sh
  b ./scripts/build_tiff.sh
  b ./scripts/build_sqlite.sh
  #./scripts/build_geotiff.sh
  # for mapnik-vector-tile
  b ./scripts/build_protobuf.sh
  if [[ ${BOOST_ARCH} != "arm" ]]; then
    b ./scripts/build_expat.sh
    b ./scripts/build_postgres.sh
    if [[ "${MINIMAL_MAPNIK:-false}" == false ]]; then
      b ./scripts/build_gdal.sh
      b ./scripts/build_pixman.sh
      b ./scripts/build_cairo.sh
      b ./scripts/build_pycairo.sh
      ./scripts/build_boost.sh --with-python
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
  upgrade_compiler
  prepare_os
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
  upgrade_compiler
  prepare_os
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
  prepare_os
  if [[ ${UNAME} == 'Linux' ]]; then
      sudo apt-get install -qq -y xutils-dev # for gccmakedep used in openssl
  fi
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
  prepare_os
  if [[ ${UNAME} == 'Linux' ]]; then
      sudo apt-get install -qq -y xutils-dev # for gccmakedep used in openssl
  fi
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
  prepare_os
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
  prepare_os
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
