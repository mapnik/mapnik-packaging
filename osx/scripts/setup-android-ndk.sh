#!/usr/bin/env bash
set -e -u
set -o pipefail
mkdir -p ${PACKAGES}
cd ${PACKAGES}

export uname_lowercase=$(echo $(uname -s) | sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/")

if [[ ! -f "android-ndk64-${ANDROID_NDK_VERSION}-${uname_lowercase}-x86_64.tar.bz2" ]]; then
    echo "downloading http://dl.google.com/android/ndk/android-ndk64-${ANDROID_NDK_VERSION}-${uname_lowercase}-x86_64.tar.bz2"
    curl -s -S -f -O -L http://dl.google.com/android/ndk/android-ndk64-${ANDROID_NDK_VERSION}-${uname_lowercase}-x86_64.tar.bz2
else
    echo "using cached http://dl.google.com/android/ndk/android-ndk64-${ANDROID_NDK_VERSION}-${uname_lowercase}-x86_64.tar.bz2"
fi

if [[ ! -d "android-ndk64-${ANDROID_NDK_VERSION}" ]]; then
    echo "unpacking android-ndk64-${ANDROID_NDK_VERSION}-${uname_lowercase}-x86_64.tar.bz2"
    tar xf android-ndk64-${ANDROID_NDK_VERSION}-${uname_lowercase}-x86_64.tar.bz2
else
    echo "using cached android-ndk64-${ANDROID_NDK_VERSION}-${uname_lowercase}-x86_64.tar.bz2"
fi