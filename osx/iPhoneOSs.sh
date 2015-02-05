#!/usr/bin/env bash

set -u

source $(dirname "$BASH_SOURCE")/iPhoneOS.sh
export ARCH_NAME="armv7s"
export MASON_PLATFORM="iPhoneOSs"
source $(dirname "$BASH_SOURCE")/settings.sh