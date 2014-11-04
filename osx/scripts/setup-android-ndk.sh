#!/usr/bin/env bash
set -e -u
set -o pipefail
mkdir -p ${PACKAGES}
cd ${PACKAGES}

export uname_lowercase=$(echo $(uname -s) | sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/")

if [[ $uname_lowercase == 'linux' ]]; then
    sudo apt-get install -y p7zip-full
fi

if [[ ! -f "android-ndk-${MASON_ANDROID_NDK_VERSION}-${uname_lowercase}-x86_64.bin" ]]; then
    echo "downloading http://dl.google.com/android/ndk/android-ndk-${MASON_ANDROID_NDK_VERSION}-${uname_lowercase}-x86_64.bin"
    curl -s -S -f -O -L http://dl.google.com/android/ndk/android-ndk-${MASON_ANDROID_NDK_VERSION}-${uname_lowercase}-x86_64.bin
else
    echo "using cached http://dl.google.com/android/ndk/android-ndk-${MASON_ANDROID_NDK_VERSION}-${uname_lowercase}-x86_64.bin"
fi

if [[ ! -d "android-ndk-${MASON_ANDROID_NDK_VERSION}" ]]; then
    echo "unpacking $(pwd)/android-ndk-${MASON_ANDROID_NDK_VERSION}-${uname_lowercase}-x86_64.bin"
    chmod a+x android-ndk-${MASON_ANDROID_NDK_VERSION}-${uname_lowercase}-x86_64.bin
    7z x ./android-ndk-${MASON_ANDROID_NDK_VERSION}-${uname_lowercase}-x86_64.bin > /dev/null
else
    echo "using cached $(pwd)/android-ndk-${MASON_ANDROID_NDK_VERSION}-${uname_lowercase}-x86_64.bin"
fi

