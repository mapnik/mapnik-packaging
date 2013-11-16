set -e 

mkdir -p ${PACKAGES}
cd ${PACKAGES}

echo '*building sqlite*'
rm -rf sqlite-autoconf-${SQLITE_VERSION}
tar xf sqlite-autoconf-${SQLITE_VERSION}.tar.gz
cd sqlite-autoconf-${SQLITE_VERSION}
export OLD_CFLAGS=$CFLAGS
export CFLAGS="-DSQLITE_ENABLE_RTREE=1 $CFLAGS"
./configure --prefix=${BUILD} --enable-static --disable-shared --disable-dependency-tracking
make -j${JOBS}
make install
export CFLAGS=$OLD_CFLAGS
cd ${PACKAGES}
