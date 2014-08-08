#!/bin/bash

set -u

source $(dirname "$BASH_SOURCE")/iPhoneSimulator.sh
export ARCH_NAME="x86_64"
export PLATFORM="iPhoneSimulator64"
source $(dirname "$BASH_SOURCE")/settings.sh