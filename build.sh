#!/bin/bash

set -e -u

function prep_osx {
  cd osx
  source MacOSX.sh
}

function prep_linux {
  cd osx
  source Linux64.sh
  export JOBS=$(($JOBS/2))
  echo "Running build with ${JOBS} parallel jobs"
  if [ "${CXX11}" = true ]; then
    sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test;
    sudo apt-get update -y
    sudo apt-get install -y gcc-4.8 g++-4.8;
    export CC="gcc-4.8";
    export CXX="g++-4.8";
  else
    sudo apt-get update -y
  fi;
}

function build_mapnik {
  sudo apt-get install -y build-essential git unzip python-dev libbz2-dev
  # postgres deps
  sudo apt-get install -y libpam0g-dev libgss-dev libkrb5-dev libldap2-dev libavahi-compat-libdnssd-dev
  ./scripts/build_core_deps.sh 1>> build.log
  #./scripts/build_deps_optional.sh 1>> build.log
  ./scripts/build_python_versions.sh
  ./scripts/build_protobuf.sh 1>> build.log
  git clone https://github.com/mapnik/mapnik.git mapnik-${STDLIB}
  cd mapnik-${STDLIB}
  if [ "${CXX11}" = false ]; then
      git checkout 2.3.x
  fi
  cd ../
  ./scripts/build_mapnik_mobile.sh
}

function build_mapnik_for_linux {
  prep_linux
  build_mapnik
}
export -f build_mapnik_for_linux

function build_osrm {
  sudo apt-get install -y build-essential git cmake lua5.1 liblua5.1-0-dev
  ./scripts/build_bzip2.sh 1>> build.log
  ./scripts/build_icu.sh 1>> build.log
  # TODO: osrm boost usage does not need icu
  ./scripts/build_boost.sh 1>> build.log
  ./scripts/build_zlib.sh 1>> build.log
  ./scripts/build_protobuf.sh 1>> build.log
  ./scripts/build_osm-pbf.sh 1>> build.log
  ./scripts/build_luabind.sh 1>> build.log
  ./scripts/build_libstxxl.sh 1>> build.log
  ./scripts/build_osrm.sh
}

function build_osrm_for_linux {
  prep_linux
  build_osrm
}
export -f build_osrm_for_linux

function build_osmium_for_linux {
  prep_linux
  build_osmium
}
export -f build_osmium_for_linux
