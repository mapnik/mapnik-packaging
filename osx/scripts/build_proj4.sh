set -e 

mkdir -p ${PACKAGES}
cd ${PACKAGES}

# proj4
echo '*building proj.4*'
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
make -j${JOBS}
# TODO - android: /bin/sh: ../src/nad2bin: cannot execute binary file
make install
cd ${PACKAGES}
