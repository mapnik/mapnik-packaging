#!/bin/bash

function build_all {
  ./scripts/download_deps.sh
  ./scripts/build_core_deps.sh 1>> build.log
  ./scripts/build_deps_optional.sh 1>> build.log
  ./scripts/build_python_versions.sh 1>> build.log
  ./scripts/build_protobuf.sh 1>> build.log
  ./scripts/build_node.sh 1>> build.log
}

function build_for_osx {
  cd osx
  source MacOSX.sh
  build_all
}

export -f build_for_osx

function build_for_linux {
  cd osx
  source Linux64.sh
  if [ "${CXX11}" = true ]; then
    sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test;
    sudo apt-get update -y
    sudo apt-get install -y gcc-4.8 g++-4.8;
    export CC="gcc-4.8";
    export CXX="g++-4.8";
    export BOOST_TOOLSET="gcc-4.8"
  else
    sudo apt-get update -y
  fi;
  sudo apt-get install -y build-essential git unzip python-dev libbz2-dev
  # postgres deps
  sudo apt-get install -y libpam0g-dev libgss-dev libkrb5-dev libldap2-dev libavahi-compat-libdnssd-dev
  build_all
}

export -f build_for_linux