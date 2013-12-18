#!/bin/bash
set -e -u

mkdir -p ${PACKAGES}
cd ${PACKAGES}

echoerr 'building icu'
rm -rf icu-${ARCH_NAME}
rm -rf icu
# *WARNING* do not set an $INSTALL variable
# it will screw up icu build scripts
export OLD_CPPFLAGS=${CPPFLAGS}
export OLD_LDFLAGS=${LDFLAGS}
export LDFLAGS="${STDLIB_LDFLAGS} ${LDFLAGS}"
# http://source.icu-project.org/repos/icu/icu/trunk/readme.html#RecBuild
# http://userguide.icu-project.org/packaging
# http://thebugfreeblog.blogspot.de/2013/05/cross-building-icu-for-applications-on.html
# U_CHARSET_IS_UTF8 is added to try to reduce icu library size (18.3)
if [ ${BOOST_ARCH} = "x86" ]; then
    export CPPFLAGS="${ICU_CORE_CPP_FLAGS}"
else
    export CPPFLAGS="${ICU_EXTRA_CPP_FLAGS}"
fi

tar xf icu4c-${ICU_VERSION2}-src.tgz
mv icu icu-${ARCH_NAME}
cd icu-${ARCH_NAME}/source
if [ $BOOST_ARCH = "arm" ]; then
    if [ -d "$(pwd)/../../icu-i386/source" ]; then
        NATIVE_BUILD_DIR="$(pwd)/../../icu-i386/source"
    elif [ -d "$(pwd)/../../icu-x86_64/source" ]; then
        NATIVE_BUILD_DIR="$(pwd)/../../icu-x86_64/source"
    else
        echo 'could not find pre-built icu from a native/host arch!'
    fi
    export CROSS_FLAGS="--with-cross-build=${NATIVE_BUILD_DIR}"
    export CPPFLAGS="${CPPFLAGS} -I$(pwd)/common -I$(pwd)/tools/tzcode/"
else
    export CROSS_FLAGS=""
fi
cp ${PREMADE_ICU_DATA_LIBRARY} ./data/in/*dat
# note: enable-draft is needed for U_ICUDATA_ENTRY_POINT
./configure ${HOST_ARG} ${CROSS_FLAGS} --prefix=${BUILD} \
--enable-draft \
--enable-static \
--with-data-packaging=archive \
--disable-shared \
--disable-tests \
--disable-extras \
--disable-layout \
--disable-icuio \
--disable-samples \
--disable-dyload
make -j${JOBS} -i -k 
make install
export LDFLAGS=${OLD_LDFLAGS}
export CPPFLAGS=${OLD_CPPFLAGS}
cd ${PACKAGES}

#if [ $UNAME = 'Darwin' ]; then
#    otool -L ${BUILD}/lib/*.dylib | grep c++
#fi

# clear out shared libs
rm -f ${BUILD}/lib/{*.so,*.dylib}
