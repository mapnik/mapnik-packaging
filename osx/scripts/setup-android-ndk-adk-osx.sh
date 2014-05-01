#!/usr/bin/env bash
set -e -u
set -o pipefail
cd ${PACKAGES}
wget http://dl.google.com/android/ndk/android-ndk-r9-darwin-x86.tar.bz2
tar xf android-ndk-r9-darwin-x86.tar.bz2