#!/bin/bash

set -u

source $(dirname "$BASH_SOURCE")/iPhoneSimulator.sh
export ARCH_NAME="x86_64"
source $(dirname "$BASH_SOURCE")/settings.sh