#!/usr/bin/env bash

set -u

export MP_PLATFORM="Android"
export MP_ANDROID_NDK_VERSION="r10c"
export MP_ANDROID_ARCH="arm"
export MP_API_LEVEL="android-21"
export MP_ANDROID_TARGET="arm"
export MP_ANDROID_CROSS_COMPILER="${MP_ANDROID_TARGET}-linux-androideabi-4.9"

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
export HOST_ARG="--host=${MP_ANDROID_TARGET}-linux-androideabi"
export MAKE="make"

source $(dirname "$BASH_SOURCE")/settings.sh

# ADT to actually run and test the binaries
# http://dl.google.com/android/adt/adt-bundle-mac-x86_64-20130729.zip
# http://dl.google.com/android/adt/adt-bundle-mac-x86_64-20130917.zip
#ADT_BUNDLE="${ROOTDIR}/adt-bundle-mac"
#PATH="${ADT_BUNDLE}/sdk/tools:${ADT_BUNDLE}/sdk/platform-tools":${PATH}

function run {
  emulator -avd Phone & ddms
}

