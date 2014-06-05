#!/bin/bash

set -u

export PLATFORM="Android"

if [[ $UNAME == 'Darwin' ]]; then
    export HOST_PLATFORM="MacOSX"
elif [[ $UNAME == 'Linux' ]]; then
    export HOST_PLATFORM="Linux"
elif
    echoerr "unknown host platform for android cross-compile: ${UNAME}"
fi

export BOOST_ARCH="arm"
export ARCH_NAME="gcc-arm"
export HOST_ARG="--host=arm-linux-androideabi"
export MAKE="make"
if [[ "${CXX11:-false}" == false ]]; then
  export CXX11=false
fi

# ADT to actually run and test the binaries
# http://dl.google.com/android/adt/adt-bundle-mac-x86_64-20130729.zip
# http://dl.google.com/android/adt/adt-bundle-mac-x86_64-20130917.zip
ADT_BUNDLE="${ROOTDIR}/adt-bundle-mac"
PATH="${ADT_BUNDLE}/sdk/tools:${ADT_BUNDLE}/sdk/platform-tools":${PATH}

source $(dirname "$BASH_SOURCE")/settings.sh

function run {
  emulator -avd Phone & ddms
}