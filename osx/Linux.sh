#!/bin/bash

set -u

export MASON_PLATFORM="Linux"
export HOST_PLATFORM="Linux"
export BOOST_ARCH="x86"
export ARCH_NAME="gcc-x86_64"
export HOST_ARG=""
if [[ "${CXX11:-false}" == false ]]; then
  export CXX11=false
fi
export MAKE="make"
source $(dirname "$BASH_SOURCE")/settings.sh
