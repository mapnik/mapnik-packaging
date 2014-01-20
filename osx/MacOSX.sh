#!/bin/bash

set -u

export PLATFORM="MacOSX"
export HOST_PLATFORM="MacOSX"
export BOOST_ARCH="x86"
export ARCH_NAME="x86_64"
export HOST_ARG=""
export ACTIVE_SDK_VERSION="10.8"
if [[ "${CXX11:-false}" != false ]]; then
  export MIN_SDK_VERSION_FLAG="-mmacosx-version-min=10.7"
else
  export MIN_SDK_VERSION_FLAG="-mmacosx-version-min=10.6"
  export CXX11=false
fi
#export MACOSX_DEPLOYMENT_TARGET=${MIN_SDK_VERSION} # breaks distutils
source $(dirname "$BASH_SOURCE")/settings.sh
