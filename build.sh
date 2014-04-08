#!/bin/bash

UNAME=$(uname -s)

function b {
  if [[ "${QUIET:-false}" != false ]]; then
    $1 1>> build.log
  else
    $1
  fi
}

function prep_osx {
  cd osx
  if [[ "${PLATFORM:-false}" != false ]]; then
      source ${PLATFORM}.sh
  else
      source MacOSX.sh
  fi
  brew install autoconf automake libtool makedepend | true
  mkdir -p ${BUILD}
  mkdir -p ${BUILD}/lib
  mkdir -p ${BUILD}/include
}

function prep_linux {
  cd osx
  source Linux.sh
  if [ "${CXX11}" = true ]; then
    echo "adding gcc-4.8 ppa"
    sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
    echo "updating apt"
    sudo apt-get update -qq -y
    echo "installing C++11 compiler"
    sudo apt-get install -qq -y gcc-4.8 g++-4.8
  else
    echo "updating apt"
    sudo apt-get update -y -qq
  fi;
  echo "installing build tools"
  sudo apt-get install -qq -y build-essential git cmake
  mkdir -p ${BUILD}
  mkdir -p ${BUILD}/lib
  mkdir -p ${BUILD}/include
}

function build_mapnik {
  set -e
  if [[ $UNAME == 'Linux' ]]; then
      prep_linux
      sudo apt-get install -qq -y build-essential git unzip python-dev zlib1g-dev python-nose
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
  export BUILD_OPTIONAL_DEPS=true
  # NOTE: harfbuzz needs pkg-config to find icu
  b ./scripts/build_pkg_config.sh
  b ./scripts/build_bzip2.sh
  b ./scripts/build_zlib.sh
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
  if [ $BUILD_OPTIONAL_DEPS ]; then
    echo 'skipping optional deps'
    b ./scripts/build_jpeg_turbo.sh
    b ./scripts/build_png.sh
    b ./scripts/build_proj4.sh
    b ./scripts/build_webp.sh
    b ./scripts/build_tiff.sh
    b ./scripts/build_sqlite.sh
    #./scripts/build_geotiff.sh
    if [[ ${BOOST_ARCH} != "arm" ]]; then
      b ./scripts/build_expat.sh
      b ./scripts/build_gdal.sh
      b ./scripts/build_postgres.sh
      b ./scripts/build_pixman.sh
      b ./scripts/build_fontconfig.sh
      b ./scripts/build_cairo.sh
      b ./scripts/build_python_versions.sh
      b ./scripts/build_pycairo.sh
    fi
  fi
  # for mapnik-vector-tile
  b ./scripts/build_protobuf.sh
  branch="master"
  if [ "${CXX11}" = false ]; then
      branch="2.3.x"
  fi
  if [ ! -d ${MAPNIK_SOURCE} ]; then
      git clone --quiet https://github.com/mapnik/mapnik.git ${MAPNIK_SOURCE} -b $branch
      git branch -v
  fi
  if [ "${CXX11}" = false ]; then
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
  set +e
}

function basic_prep {
  if [[ $UNAME == 'Linux' ]]; then
      prep_linux
      sudo apt-get install -qq -y build-essential git unzip zlib1g-dev
  else
      prep_osx
  fi
  echo "Running build with ${JOBS} parallel jobs"
}

function build_osrm {
  set -e
  basic_prep
  b ./scripts/build_bzip2.sh
  b ./scripts/build_libxml2.sh
  b ./scripts/build_icu.sh
  b ./scripts/build_lua.sh
  # TODO: osrm boost usage does not need icu
  ./scripts/build_boost.sh --with-iostreams --with-program_options --with-thread --with-filesystem --disable-filesystem2 --with-system --with-regex
  b ./scripts/build_zlib.sh
  b ./scripts/build_protobuf.sh
  b ./scripts/build_osm-pbf.sh
  b ./scripts/build_luabind.sh
  b ./scripts/build_libstxxl.sh
  ./scripts/build_osrm.sh
  #./scripts/package_tarball.sh
  set +e
}

export -f build_osrm

function build_http {
  basic_prep
  b ./scripts/build_zlib.sh
  b ./scripts/build_libuv.sh
  b ./scripts/build_openssl.sh
  b ./scripts/build_curl.sh
  b ./scripts/build_glfw.sh
  set +e
}
export -f build_http

function build_osm2pgsql {
  basic_prep
  b ./scripts/build_zlib.sh
  b ./scripts/build_bzip2.sh
  b ./scripts/build_geos.sh
  b ./scripts/build_proj4.sh
  b ./scripts/build_postgres.sh
  b ./scripts/build_protobuf.sh
  b ./scripts/build_protobuf_c.sh
  set +e
}
export -f build_osm2pgsql

function build_liblas {
  basic_prep
  b ./scripts/build_zlib.sh
  b ./scripts/build_jpeg_turbo.sh
  b ./scripts/build_png.sh
  b ./scripts/build_tiff.sh
  b ./scripts/build_geotiff.sh
  b ./scripts/build_geos.sh
  b ./scripts/build_sqlite.sh
  b ./scripts/build_proj4.sh
  b ./scripts/build_spatialite.sh
  b ./scripts/build_expat.sh
  b ./scripts/build_postgres.sh
  b ./scripts/build_gdal.sh
  b ./scripts/build_laszip.sh
  ./scripts/build_boost.sh --with-thread --with-program_options
  b ./scripts/build_liblas.sh
  set +e
}
export -f build_liblas
