#!/bin/bash

set -u

export PLATFORM="Linux"
export HOST_PLATFORM="Linux"
export BOOST_ARCH="x86"
export ARCH_NAME="gcc-x86_64"
export HOST_ARG=""
export CXX="clang++"
alias make=gmake
# but above does not work for freetype, so we do:
ln -s `which gmake` `pwd`/make
export PATH=`pwd`:$PATH
if [[ "${CXX11:-false}" == false ]]; then
  export CXX11=false
fi
source $(dirname "$BASH_SOURCE")/settings.sh
