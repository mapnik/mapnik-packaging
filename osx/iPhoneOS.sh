#!/usr/bin/env bash

set -u

export MASON_PLATFORM="iPhoneOS"
export XCODE_PLATFORM="${MASON_PLATFORM}"
export HOST_PLATFORM="MacOSX"
export BOOST_ARCH="arm"
export ARCH_NAME="armv7"
export HOST_ARG="--host=arm-apple-darwin"
export ACTIVE_SDK_VERSION="`xcrun --sdk iphoneos --show-sdk-version`"
export MIN_SDK_VERSION_FLAG="-miphoneos-version-min=${ACTIVE_SDK_VERSION}"
export MAKE="make"

source $(dirname "$BASH_SOURCE")/settings.sh

# learn about arm: http://wanderingcoder.net/2010/07/19/ought-arm/

# todo need: -stdlib=libc++ in cflags as well as linker flags
#-x objective-c++ -fmessage-length=0 -std=gnu++11 -stdlib=libc++ -fobjc-arc -Wno-trigraphs -fpascal-strings -Wno-missing-field-initializers -Wno-missing-prototypes -Wreturn-type -Wno-implicit-atomic-properties -Wno-receiver-is-weak -Wno-non-virtual-dtor -Wno-overloaded-virtual -Wno-exit-time-destructors -Wduplicate-method-match -Wformat -Wno-missing-braces -Wparentheses -Wswitch -Wno-unused-function -Wno-unused-label -Wno-unused-parameter -Wunused-variable -Wunused-value -Wempty-body -Wuninitialized -Wno-unknown-pragmas -Wno-shadow -Wno-four-char-constants -Wno-conversion -Wconstant-conversion -Wint-conversion -Wenum-conversion -Wno-shorten-64-to-32 -Wno-newline-eof -Wno-selector -Wno-strict-selector-match -Wno-undeclared-selector -Wno-deprecated-implementations -Wno-c++11-extensions -fstrict-aliasing -Wprotocol -Wdeprecated-declarations -Winvalid-offsetof -fvisibility-inlines-hidden -Wno-sign-conversion
