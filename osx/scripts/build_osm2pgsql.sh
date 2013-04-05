source MacOSX.sh

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
patch configure.ac ${PATCHES}/osm2pgsql-configure.diff -N
patch Makefile.am ${PATCHES}/osm2pgsql-datadir.diff -N
make clean
make distclean
./autogen.sh
OLD_LDFLAGS=$LDFLAGS
export LDFLAGS="${LDFLAGS} -lldap -lpam -lssl -lcrypto -lkrb5"
export OSM2PGSQL_TARGET="${STAGING}/osm2pgsql-osx"
export DESTDIR=OSM2PGSQL_TARGET
./configure --prefix=/usr/local \
--with-zlib=${BUILD} \
--with-bzip2=${BUILD} \
--with-geos=${BUILD}/bin/geos-config \
--with-proj=${BUILD} \
--with-protobuf-c=${BUILD} \
--with-postgresql=${BUILD}/bin/pg_config
make -j${JOBS}
make install
export LDFLAGS="$OLD_LDFLAGS"
export DESTDIR=

# add docs for installing
echo '
osm2pgsql os x binary
---------------------

1) Installing

osm2pgsql is a command line program.

To use it you open the Terminal.app in /Applications/Utilities.

We recommended putting osm2pgsql into /usr/local/bin/osm2pgsql which is where the program
would be installed by default if you build it from source.

Then put the "default.style" in /usr/local/share/osm2pgsql/default.style.

Alternatively you can run osm2pgsql from anywhere and pass the -S option to point to
the location of the default.style.

For example if you just want to use osm2pgsql locally (within the directory structure
found beside this README.txt) you could put this directory on your Desktop, open Terminal.app
and the type the following commands to test osm2pgsql can be run from the command line:

    cd ~/Desktop/osm2pgsql-osx
    cd usr/local/bin
    ./osm2pgsql -v # should show the version

2) Usage

This assumes osm2pgsql is in /usr/local/bin/

Get help:

    /usr/local/bin/osm2pgsql -h

Show the version:

    /usr/local/bin/osm2pgsql -v

Import an .osm file named 'test.osm' into a postgres named 'osm':

    /usr/local/bin/osm2pgsql -d osm  test.osm

' > ${OSM2PGSQL_TARGET}/README.txt