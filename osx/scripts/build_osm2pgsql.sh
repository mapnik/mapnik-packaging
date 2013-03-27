source settings.sh

cd ${PACKAGES}

echo '*building geos*'
rm -rf geos-${GEOS_VERSION}
tar xf geos-${GEOS_VERSION}.tar.bz2
cd geos-${GEOS_VERSION}
./configure --prefix=${BUILD} --enable-static --disable-shared \
--disable-dependency-tracking
make -j${JOBS}
make install
cd ${PACKAGES}

echo '*building protobuf C++*'
rm -rf cd protobuf-${PROTOBUF_VERSION}
tar xf protobuf-${PROTOBUF_VERSION}.tar.bz2
cd protobuf-${PROTOBUF_VERSION}
./configure --prefix=${BUILD} --enable-static --disable-shared \
--disable-dependency-tracking
make -j${JOBS}
make install
cd ${PACKAGES}

echo '*building protobuf C*'
rm -rf cd protobuf-c-${PROTOBUF_C_VERSION}
tar xf protobuf-c-${PROTOBUF_C_VERSION}.tar.gz
cd protobuf-c-${PROTOBUF_C_VERSION}
./configure --prefix=${BUILD} --enable-static --disable-shared \
--disable-dependency-tracking
make -j${JOBS}
make install
cd ${PACKAGES}


echo '*building osm2pgsql*'
#svn co http://svn.openstreetmap.org/applications/utils/export/osm2pgsql/
cd ${ROOTDIR}/osm2pgsql
./autogen.sh
OLD_LDFLAGS=$LDFLAGS
export LDFLAGS="${LDFLAGS} -lldap -lpam -lssl -lcrypto -lkrb5"
./configure --prefix=${STAGING} \
--with-zlib=${BUILD} \
--with-bzip2=${BUILD} \
--with-geos=${BUILD}/bin/geos-config \
--with-proj=${BUILD} \
--with-protobuf-c=${BUILD} \
--with-postgresql=${BUILD}/bin/pg_config
make -j${JOBS}
make install
$LDFLAGS=$OLD_LDFLAGS