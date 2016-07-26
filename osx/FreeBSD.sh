#!/usr/bin/env bash

set -u

export MASON_PLATFORM="Linux"
export HOST_PLATFORM="Linux"
export BOOST_ARCH="x86"
export ARCH_NAME="gcc-x86_64"
export HOST_ARG=""
export CXX="clang++"
export MAKE="gmake"
source $(dirname "$BASH_SOURCE")/settings.sh
