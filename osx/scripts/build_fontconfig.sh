set -e 
mkdir -p ${PACKAGES}
cd ${PACKAGES}

# fontconfig
echo '*building fontconfig*'
rm -rf fontconfig-${FONTCONFIG_VERSION}
tar xf fontconfig-${FONTCONFIG_VERSION}.tar.gz
cd fontconfig-${FONTCONFIG_VERSION}
./configure --enable-static --disable-shared --disable-dependency-tracking --prefix=${BUILD} \
    --with-expat=${BUILD}
make -j${JOBS}
make install
cd ${PACKAGES}
