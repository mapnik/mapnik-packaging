#!/usr/bin/env bash

set -u

export MP_PLATFORM="Linux"
export HOST_PLATFORM="Linux"
export BOOST_ARCH="x86"
export ARCH_NAME="gcc-x86_64"
export HOST_ARG=""
export MAKE="make"
source $(dirname "$BASH_SOURCE")/settings.sh
