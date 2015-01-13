#!/bin/bash

set -u

export MASON_PLATFORM="ArmLinux"
export HOST_PLATFORM="Linux"
export BOOST_ARCH="arm"
export ARCH_NAME="armv7"
export CXX="g++"
export CC="gcc"
export MAKE="make"
# default to C++11 for this platform
if [[ "${CXX11:-false}" == false ]]; then
  export CXX11=true
fi
source $(dirname "$BASH_SOURCE")/settings.sh
