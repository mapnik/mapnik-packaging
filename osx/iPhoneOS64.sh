#!/bin/bash

set -u

source $(dirname "$BASH_SOURCE")/iPhoneOS.sh
export ARCH_NAME="arm64"
export PLATFORM="iPhoneOS64"
source $(dirname "$BASH_SOURCE")/settings.sh