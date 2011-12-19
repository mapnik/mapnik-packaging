set -e 

mkdir -p ${BUILD}
cd ${PACKAGES}

# icu
# *WARNING* do not set an $INSTALL variable
# it will screw up icu build scripts
tar xf icu4c-${ICU_VERSION2}-src.tgz
cd icu/source
./runConfigureICU MacOSX --prefix=${BUILD} \
--disable-samples \
--disable-static \
--enable-shared \
--with-library-bits=64

make -j${JOBS}
make install
cd ${PACKAGES}


# boost
B2_VERBOSE=""
#B2_VERBOSE="-d2"
tar xjf boost_${BOOST_VERSION2}.tar.bz2
cd boost_${BOOST_VERSION2}
# patch python build to ensure we do not link boost_python to python
patch tools/build/v2/tools/python.jam < ${ROOTDIR}/patches/python_jam.diff
./bootstrap.sh

# static libs
./b2 --prefix=${BUILD} -j${JOBS} ${B2_VERBOSE} \
  --with-thread \
  --with-filesystem \
  --disable-filesystem2 \
  --with-program_options --with-system --with-chrono \
  toolset=darwin \
  macosx-version=10.6 \
  address-model=32_64 \
  architecture=x86 \
  link=static \
  variant=release \
  stage install

# dynamic regex
./b2 --prefix=${BUILD} -j${JOBS} ${B2_VERBOSE} \
  --with-regex \
  toolset=darwin \
  macosx-version=10.6 \
  address-model=32_64 \
  architecture=x86 \
  link=shared \
  variant=release \
  -sHAVE_ICU=1 -sICU_PATH=${BUILD} \
  stage

cp stage/lib/libboost_regex.dylib ${BUILD}/lib/libboost_regex-mapnik.dylib
install_name_tool -id @loader_path/libboost_regex-mapnik.dylib ${BUILD}/lib/libboost_regex-mapnik.dylib
ln -s ${BUILD}/lib/libboost_regex-mapnik.dylib ${BUILD}/lib/libboost_regex.dylib

# bcp
./b2 --prefix=${BUILD} -j${JOBS} ${B2_VERBOSE} stage tools/bcp

# python
<<COMMENT
./b2 --prefix=${BUILD} -j${JOBS} ${B2_VERBOSE} \
  --with-python \
  toolset=darwin \
  macosx-version=10.6 \
  address-model=32_64 \
  architecture=x86 \
  link=shared \
  variant=release \
  -sHAVE_ICU=1 -sICU_PATH=${BUILD} \
  stage install
COMMENT


# boost python for various versions are done in python script
#python ${ROOTDIR}/scripts/build_boost_pythons.py 2.5 64
#mv stage/lib/libboost_python.dylib stage/lib/libboost_python-2.5.dylib
#cp stage/lib/libboost_python-2.5.dylib ${BUILD}/lib/libboost_python-2.5.dylib
#install_name_tool -id @loader_path/libboost_python-2.5.dylib ${BUILD}/lib/libboost_python-2.5.dylib

python ${ROOTDIR}/scripts/build_boost_pythons.py 2.6 64
mv stage/lib/libboost_python.dylib stage/lib/libboost_python-2.6.dylib
cp stage/lib/libboost_python-2.6.dylib ${BUILD}/lib/libboost_python-2.6.dylib
install_name_tool -id @loader_path/libboost_python-2.6.dylib ${BUILD}/lib/libboost_python-2.6.dylib

python ${ROOTDIR}/scripts/build_boost_pythons.py 2.7 64
mv stage/lib/libboost_python.dylib stage/lib/libboost_python-2.7.dylib
cp stage/lib/libboost_python27.dylib ${BUILD}/lib/libboost_python-2.7.dylib
install_name_tool -id @loader_path/libboost_python-2.7.dylib ${BUILD}/lib/libboost_python-2.7.dylib

#python ${ROOTDIR}/scripts/build_boost_pythons.py 3.2 64
#mv stage/lib/libboost_python3.dylib stage/lib/libboost_python-3.2.dylib
#cp stage/lib/libboost_python-3.2.dylib ${BUILD}/lib/libboost_python-3.2.dylib
#install_name_tool -id @loader_path/libboost_python-3.2.dylib ${BUILD}/lib/libboost_python-3.2.dylib

cd ${PACKAGES}

# freetype
tar xf freetype-${FREETYPE_VERSION}.tar.bz2
cd freetype-${FREETYPE_VERSION}
./configure --prefix=${BUILD} --enable-static --disable-shared --disable-dependency-tracking
make -j${JOBS}
make install
cd ${PACKAGES}

# proj4
cd proj-trunk/nad
unzip -o ../../proj-datumgrid-${PROJ_GRIDS_VERSION}.zip
cd ../
./configure --prefix=${BUILD} --enable-static --disable-shared --disable-dependency-tracking
make -j${JOBS}
make install
cd ${PACKAGES}

# libpng
tar xf libpng-${LIBPNG_VERSION}.tar.gz
cd libpng-${LIBPNG_VERSION}
./configure --prefix=${BUILD} --enable-static --disable-shared --disable-dependency-tracking
make -j${JOBS}
make install
cd ${PACKAGES}

# libjpeg
tar xf jpegsrc.v${JPEG_VERSION}.tar.gz
cd jpeg-${JPEG_VERSION}
./configure --prefix=${BUILD} --enable-static --disable-shared --disable-dependency-tracking
make -j${JOBS}
make install
cd ${PACKAGES}

# libtiff
tar xf tiff-${LIBTIFF_VERSION}.tar.gz
cd tiff-${LIBTIFF_VERSION}
./configure --prefix=${BUILD} --enable-static --disable-shared --disable-dependency-tracking
make -j${JOBS}
make install
cd ${PACKAGES}

# sqlite
tar xf sqlite-autoconf-${SQLITE_VERSION}.tar.gz
cd sqlite-autoconf-${SQLITE_VERSION}
export CFLAGS="-DSQLITE_ENABLE_RTREE=1 "$CFLAGS
./configure --prefix=${BUILD} --enable-static --disable-shared --disable-dependency-tracking
make -j${JOBS}
make install
cd ${PACKAGES}


<<COMMENT
# gettext which provides libintl for libpq
tar xf gettext-${GETTEXT_VERSION}.tar.gz
cd gettext-${GETTEXT_VERSION}
./configure --prefix=${BUILD} --enable-static --disable-shared --disable-dependency-tracking \
--without-included-gettext --disable-debug --without-included-glib \
--without-included-libcroco  --without-included-libxml \
--without-emacs --without-git --without-cvs
make -j${JOBS}
make install
cd ${PACKAGES}
COMMENT

# postgres
<<COMMENT
postgres/INSTALL has:
       Client-only installation: If you want to install only the client
       applications and interface libraries, then you can use these
       commands:
gmake -C src/bin install
gmake -C src/include install
gmake -C src/interfaces install
gmake -C doc install
COMMENT

cd ${PACKAGES}
tar xf postgresql-${POSTGRES_VERSION}.tar.bz2
mv postgresql-${POSTGRES_VERSION} postgresql-${POSTGRES_VERSION}-64
tar xf postgresql-${POSTGRES_VERSION}.tar.bz2
mv postgresql-${POSTGRES_VERSION} postgresql-${POSTGRES_VERSION}-32


# 64 bit build
cd ${PACKAGES}
cd postgresql-${POSTGRES_VERSION}-64
export ARCHFLAGS='-arch x86_64'
export CFLAGS="${OPTIMIZATION} ${ARCHFLAGS} -D_FILE_OFFSET_BITS=64"
export CXXFLAGS="${CFLAGS}"
export LDFLAGS="${OPTIMIZATION} ${ARCHFLAGS} -Wl,-search_paths_first -headerpad_max_install_names"
./configure --prefix=${BUILD} --enable-shared \
--with-openssl --with-pam --with-krb5 --with-gssapi --with-ldap --enable-thread-safety \
--with-bonjour --with-libxml \
LD=${CC}
make -j${JOBS}
make install

# 32 bit build
cd ${PACKAGES}
cd postgresql-${POSTGRES_VERSION}-32
export ARCHFLAGS='-arch i386'
export CFLAGS="${OPTIMIZATION} ${ARCHFLAGS} -D_FILE_OFFSET_BITS=64"
export CXXFLAGS="${CFLAGS}"
export LDFLAGS="${OPTIMIZATION} ${ARCHFLAGS} -Wl,-search_paths_first -headerpad_max_install_names"
LOCAL_BUILD=`pwd`/stage
./configure --prefix=${LOCAL_BUILD} --enable-shared \
--with-openssl --with-pam --with-krb5 --with-gssapi --with-ldap --enable-thread-safety \
--with-bonjour --with-libxml \
LD=${CC}
make -j${JOBS}
make install

rm ${ROOTDIR}/build/lib/libpq*dylib
cp ${ROOTDIR}/build/lib/libpq.a ${LOCAL_BUILD}/lib/libpg64.a
cp ${ROOTDIR}/build/lib/libpgport.a ${LOCAL_BUILD}/lib/libpgport64.a

# remake universal client lib
lipo -create ${LOCAL_BUILD}/lib/libpg64.a ${LOCAL_BUILD}/lib/libpq.a -output ${ROOTDIR}/build/lib/libpq.a
lipo -create ${LOCAL_BUILD}/lib/libpgport64.a ${LOCAL_BUILD}/lib/libpq.a -output ${ROOTDIR}/build/lib/libpgport.a

# re-set default ARCHFLAGS settings
source ${ROOTDIR}/settings.sh

cd ${PACKAGES}

tar xf gdal-${GDAL_VERSION}.tar.gz
cd gdal-${GDAL_VERSION}
./configure --prefix=${BUILD} --enable-static --disable-shared --disable-dependency-tracking \
--with-libtiff=${BUILD} \
--with-jpeg=${BUILD} \
--with-png=${BUILD} \
--with-static-proj4=${BUILD} \
--with-sqlite3=no \
--with-spatialite=no \
--with-curl=no \
--with-geos=no \
--with-pcraster=no \
--with-cfitsio=no \
--with-odbc=no \
--with-libkml=no \
--with-pcidsk=no \
--with-jasper=no \
--with-gif=no \
--with-pg=no \
--with-hide-internal-symbols=yes \
--with-vfk=no \
--with-grib=no

make -j${JOBS}
make install
cd ${PACKAGES}

# TODO - cairo and friends
