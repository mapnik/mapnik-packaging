#!/usr/bin/env bash
set -e -u
set -o pipefail
mkdir -p ${PACKAGES}
cd ${PACKAGES}

if [[ ! -f "android-ndk-${ANDROID_NDK_VERSION}-${platform}-x86_64.tar.bz2" ]]; then
    echoerr "downloading http://dl.google.com/android/ndk/android-ndk-${ANDROID_NDK_VERSION}-${platform}-x86_64.tar.bz2"
    ${SYSTEM_CURL} -s -S -f -O -L http://dl.google.com/android/ndk/android-ndk-${ANDROID_NDK_VERSION}-${platform}-x86_64.tar.bz2
else
    echoerr "using cached http://dl.google.com/android/ndk/android-ndk-${ANDROID_NDK_VERSION}-${platform}-x86_64.tar.bz2"
fi

if [[ ! -d "android-ndk-${ANDROID_NDK_VERSION}" ]]; then
    echoerr "unpacking android-ndk-${ANDROID_NDK_VERSION}-${platform}-x86_64.tar.bz2"
    tar xf android-ndk-${ANDROID_NDK_VERSION}-${platform}-x86_64.tar.bz2
else
    echoerr "using cached android-ndk-${ANDROID_NDK_VERSION}-${platform}-x86_64.tar.bz2"
fi