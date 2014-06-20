#!/usr/bin/env bash
set -e -u
set -o pipefail
mkdir -p ${PACKAGES}
cd ${PACKAGES}

if [ ! -f tbb42_20140416oss_src.tgz ]; then
    echoerr "downloading intel tbb"
    curl -s -S -f -O -L https://www.threadingbuildingblocks.org/sites/default/files/software_releases/source/tbb42_20140416oss_src.tgz
else
    echoerr "using cached node at tbb42_20140416oss_src.tgz"
fi

echoerr 'building tbb'

if [[ $CXX11 == true ]]; then
    rm -rf tbb42_20140416oss
    tar xf tbb42_20140416oss_src.tgz
    cd tbb42_20140416oss
    patch -N -p1 <  ${PATCHES}/tbb_compiler_override.diff || true
    # note: static linking not allowed: http://www.threadingbuildingblocks.org/faq/11
    if [[ $UNAME == 'Darwin' ]]; then
    $MAKE -j${JOBS} tbb_build_prefix=BUILDPREFIX arch=intel64 cpp0x=1 stdlib=libc++ compiler=clang tbb_build_dir=$(pwd)/build
    else
    $MAKE -j${JOBS} tbb_build_prefix=BUILDPREFIX arch=intel64 cpp0x=1 stdlib=libc++ tbb_build_dir=$(pwd)/build
    fi

    # custom install
    if [[ ${UNAME} == "Darwin" ]]; then
        cp $(pwd)/build/BUILDPREFIX_release/libtbb.dylib $BUILD/lib/
        cp $(pwd)/build/BUILDPREFIX_release/libtbbmalloc.dylib $BUILD/lib/
    else
        cp $(pwd)/build/BUILDPREFIX_release/libtbb*so* $BUILD/lib/
    fi
    cp -r $(pwd)/include/tbb ${BUILD}/include/
else
    echoerr 'skipping libtbb build since we only target c++11 mode'
fi