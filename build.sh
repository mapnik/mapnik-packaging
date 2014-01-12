#!/bin/bash -u -x

function prep_osx {
  cd osx
  source MacOSX.sh
  mkdir -p ${BUILD}
  mkdir -p ${BUILD}/lib
  mkdir -p ${BUILD}/include
}

function prep_linux {
  cd osx
  source Linux64.sh
  echo "Running build with ${JOBS} parallel jobs"
  if [ "${CXX11}" = true ]; then
    sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test;
    sudo apt-get update -y
    sudo apt-get install -y gcc-4.8 g++-4.8;
    if [ "${CXX}" = "g++" ]; then
      export CC="gcc-4.8";
      export CXX="g++-4.8";
    fi
  else
    sudo apt-get update -y
  fi;
  mkdir -p ${BUILD}
  mkdir -p ${BUILD}/lib
  mkdir -p ${BUILD}/include
}

function build_mapnik {
  ./scripts/build_bzip2.sh 1>> build.log
  ./scripts/build_core_deps.sh 1>> build.log
  ./scripts/build_deps_optional.sh 1>> build.log
  ./scripts/build_python_versions.sh
  ./scripts/build_protobuf.sh 1>> build.log
  if [ ! -f mapnik-${STDLIB} ]; then
      git clone https://github.com/mapnik/mapnik.git mapnik-${STDLIB}
  fi
  if [ "${CXX11}" = false ]; then
      cd mapnik-${STDLIB}
      git checkout 2.3.x
      cd ../
  fi
  ./scripts/build_mapnik.sh
  ./scripts/test_mapnik.sh
  #./scripts/package_tarball.sh
}

function build_mapnik_for_linux {
  prep_linux
  sudo apt-get install -y build-essential git unzip python-dev
  # postgres deps
  sudo apt-get install -y libpam0g-dev libgss-dev libkrb5-dev libldap2-dev libavahi-compat-libdnssd-dev
  build_mapnik
}
export -f build_mapnik_for_linux

function build_mapnik_for_osx {
  prep_osx
  build_mapnik
}
export -f build_mapnik_for_osx

function build_osrm {
  ./scripts/build_bzip2.sh 1>> build.log
  ./scripts/build_icu.sh 1>> build.log
  # TODO: osrm boost usage does not need icu
  ./scripts/build_boost.sh "--with-iostreams --with-program_options --with-thread --with-filesystem --disable-filesystem2 --with-system --with-regex" 1>> build.log
  ./scripts/build_zlib.sh 1>> build.log
  ./scripts/build_protobuf.sh 1>> build.log
  ./scripts/build_osm-pbf.sh 1>> build.log
  ./scripts/build_luabind.sh 1>> build.log
  ./scripts/build_libstxxl.sh 1>> build.log
  ./scripts/build_osrm.sh
  #./scripts/package_tarball.sh
}

function build_osrm_for_linux {
  prep_linux
  sudo apt-get install -y build-essential git cmake lua5.1 liblua5.1-0-dev
  build_osrm
}
export -f build_osrm_for_linux

function build_osrm_for_osx {
  prep_osx
  build_osrm
}
export -f build_osrm_for_osx
