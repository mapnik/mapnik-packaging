#!/usr/bin/env bash

set -u

source $(dirname "$BASH_SOURCE")/iPhoneSimulator.sh
export ARCH_NAME="x86_64"
export MASON_PLATFORM="iPhoneSimulator64"
source $(dirname "$BASH_SOURCE")/settings.sh