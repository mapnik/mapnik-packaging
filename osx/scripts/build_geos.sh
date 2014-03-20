#!/bin/bash
set -e -u

mkdir -p ${PACKAGES}
cd ${PACKAGES}

download geos-${GEOS_VERSION}.tar.bz2

echoerr 'building geos'
LDFLAGS="${STDLIB_LDFLAGS} ${LDFLAGS}"
# note: we put ${STDLIB_CXXFLAGS} into CXX instead of CXXFLAGS due to libtool oddity:
# http://stackoverflow.com/questions/16248360/autotools-libtool-link-library-with-libstdc-despite-stdlib-libc-option-pass
CXX="${CXX} ${STDLIB_CXXFLAGS}"
rm -rf geos-${GEOS_VERSION}
tar xf geos-${GEOS_VERSION}.tar.bz2
cd geos-${GEOS_VERSION}
if [[ ${CXX11} == true ]]; then
  patch -N configure ${PATCHES}/geos-ansi.diff
fi
./configure ${HOST_ARG} \
--prefix=${BUILD} --disable-shared --enable-static \
--disable-dependency-tracking
make -j${JOBS}
make install
cd ${PACKAGES}

#check_and_clear_libs