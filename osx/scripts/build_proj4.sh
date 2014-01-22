#!/bin/bash
set -e -u

mkdir -p ${PACKAGES}
cd ${PACKAGES}

download proj-datumgrid-${PROJ_GRIDS_VERSION}.zip
download proj-${PROJ_VERSION}.tar.gz

# proj4
echoerr 'building proj.4'
rm -rf proj-${PROJ_VERSION}
tar xf proj-${PROJ_VERSION}.tar.gz
cd proj-${PROJ_VERSION}/nad
unzip -o ../../proj-datumgrid-${PROJ_GRIDS_VERSION}.zip
cd ../
# wget -O config.guess http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=HEAD
# wget -O config.sub http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=HEAD
cp ${PATCHES}/config.guess .
cp ${PATCHES}/config.sub .
./configure --prefix=${BUILD} --without-mutex ${HOST_ARG} \
--with-jni=no --enable-static --disable-shared --disable-dependency-tracking
# nad2bin cannot be run in cross compiler environment
if [ ${BOOST_ARCH} != "arm" ]; then
    # TODO - android: /bin/sh: ../src/nad2bin: cannot execute binary file
    set +e
    make -j${JOBS} -i -k
    make install -i -k
    set -e
else
    make -j${JOBS}
    make install
fi
cd ${PACKAGES}
