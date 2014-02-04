#!/bin/bash

set -u

export PLATFORM="iPhoneSimulator"
export HOST_PLATFORM="MacOSX"
export BOOST_ARCH="x86"
export ARCH_NAME="i386"
export HOST_ARG="--host=i686-apple-darwin11"
export ACTIVE_SDK_VERSION="7.0"
export MIN_SDK_VERSION_FLAG="-miphoneos-version-min=${ACTIVE_SDK_VERSION}"
if [[ "${CXX11:-false}" == false ]]; then
  export CXX11=false
fi

source $(dirname "$BASH_SOURCE")/settings.sh
