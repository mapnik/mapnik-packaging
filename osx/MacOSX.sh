#!/usr/bin/env bash

set -u

export MASON_PLATFORM="MacOSX"
export XCODE_PLATFORM="${MASON_PLATFORM}"
export HOST_PLATFORM="MacOSX"
export BOOST_ARCH="x86"
export ARCH_NAME="x86_64"
export HOST_ARG="--host x86_64-apple-darwin"
export ACTIVE_SDK_VERSION="`xcrun --sdk macosx --show-sdk-version`"
export MIN_SDK_VERSION_FLAG="-mmacosx-version-min=10.8"
export MAKE="make"
#export MACOSX_DEPLOYMENT_TARGET=${MIN_SDK_VERSION} # breaks distutils
source $(dirname "$BASH_SOURCE")/settings.sh
