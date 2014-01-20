#!/bin/bash

set -u

source $(dirname "$BASH_SOURCE")/iPhoneOS.sh
export ARCH_NAME="armv7s"
source $(dirname "$BASH_SOURCE")/settings.sh