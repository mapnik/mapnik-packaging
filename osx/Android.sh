#!/bin/bash

set -u

export MASON_PLATFORM="Android"
export MASON_ANDROID_NDK_VERSION="r10b"
export MASON_ANDROID_ARCH="arm64"
export MASON_API_LEVEL="android-L"
export MASON_ANDROID_TARGET="aarch64"
export MASON_ANDROID_CROSS_COMPILER="${MASON_ANDROID_TARGET}-linux-android-4.9"

UNAME=$(uname -s);
if [[ $UNAME == 'Darwin' ]]; then
    export HOST_PLATFORM="MacOSX"
elif [[ $UNAME == 'Linux' ]]; then
    export HOST_PLATFORM="Linux"
else
    echoerr "unknown host platform for android cross-compile: ${UNAME}"
fi

export BOOST_ARCH="arm"
export ARCH_NAME="gcc-arm"
export HOST_ARG="--host=${MASON_ANDROID_TARGET}-linux-android"
export MAKE="make"
if [[ "${CXX11:-false}" == false ]]; then
  export CXX11=false
fi

source $(dirname "$BASH_SOURCE")/settings.sh

# ADT to actually run and test the binaries
# http://dl.google.com/android/adt/adt-bundle-mac-x86_64-20130729.zip
# http://dl.google.com/android/adt/adt-bundle-mac-x86_64-20130917.zip
#ADT_BUNDLE="${ROOTDIR}/adt-bundle-mac"
#PATH="${ADT_BUNDLE}/sdk/tools:${ADT_BUNDLE}/sdk/platform-tools":${PATH}

function run {
  emulator -avd Phone & ddms
}