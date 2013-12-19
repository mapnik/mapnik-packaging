#!/bin/bash
set -e -u -x

cd ${PACKAGES}
wget http://dl.google.com/android/ndk/android-ndk-r9-darwin-x86.tar.bz2
tar xf android-ndk-r9-darwin-x86.tar.bz2