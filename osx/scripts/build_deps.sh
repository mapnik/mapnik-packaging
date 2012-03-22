set -e 

mkdir -p ${BUILD}
cd ${PACKAGES}

# icu
echo '*building icu*'
# *WARNING* do not set an $INSTALL variable
# it will screw up icu build scripts
tar xf icu4c-${ICU_VERSION2}-src.tgz
cd icu/source
./runConfigureICU MacOSX --prefix=${BUILD} \
--disable-samples \
--enable-static \
--disable-shared \
--with-library-bits=64 \
--with-data-packaging=archive

make -j${JOBS}
make install
cd ${PACKAGES}


# boost
echo '*building boost*'
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
  address-model=64 \
  architecture=x86 \
  link=static \
  variant=release \
  stage install

# regex separately
./b2 --prefix=${BUILD} -j${JOBS} ${B2_VERBOSE} \
  linkflags="$LDFLAGS -L$BUILD/lib -licudata -licuuc" \
  cxxflags="$CXXFLAGS -DU_STATIC_IMPLEMENTATION=1" \
  --with-regex \
  toolset=darwin \
  macosx-version=10.6 \
  address-model=64 \
  architecture=x86 \
  link=static \
  variant=release \
  -sHAVE_ICU=1 -sICU_PATH=${BUILD} \
  stage install

#cp stage/lib/libboost_regex.dylib ${BUILD}/lib/libboost_regex-mapnik.dylib
#install_name_tool -id @loader_path/libboost_regex-mapnik.dylib ${BUILD}/lib/libboost_regex-mapnik.dylib
#ln -s ${BUILD}/lib/libboost_regex-mapnik.dylib ${BUILD}/lib/libboost_regex.dylib

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

echo '*building boost python versions*'

python ${ROOTDIR}/scripts/build_boost_pythons.py 2.6 64
mv stage/lib/libboost_python.a stage/lib/libboost_python-2.6.a
cp stage/lib/libboost_python-2.6.a ${BUILD}/lib/libboost_python-2.6.a
#mv stage/lib/libboost_python.dylib stage/lib/libboost_python-2.6.dylib
#cp stage/lib/libboost_python-2.6.dylib ${BUILD}/lib/libboost_python-2.6.dylib
#install_name_tool -id @loader_path/libboost_python-2.6.dylib ${BUILD}/lib/libboost_python-2.6.dylib

python ${ROOTDIR}/scripts/build_boost_pythons.py 2.7 64
mv stage/lib/libboost_python.a stage/lib/libboost_python-2.7.a
cp stage/lib/libboost_python-2.7.a ${BUILD}/lib/libboost_python-2.7.a

#mv stage/lib/libboost_python.dylib stage/lib/libboost_python-2.7.dylib
#cp stage/lib/libboost_python27.dylib ${BUILD}/lib/libboost_python-2.7.dylib
#install_name_tool -id @loader_path/libboost_python-2.7.dylib ${BUILD}/lib/libboost_python-2.7.dylib

#python ${ROOTDIR}/scripts/build_boost_pythons.py 3.2 64
#mv stage/lib/libboost_python3.dylib stage/lib/libboost_python-3.2.dylib
#cp stage/lib/libboost_python-3.2.dylib ${BUILD}/lib/libboost_python-3.2.dylib
#install_name_tool -id @loader_path/libboost_python-3.2.dylib ${BUILD}/lib/libboost_python-3.2.dylib

cd ${PACKAGES}

# freetype
echo '*building freetype*'
tar xf freetype-${FREETYPE_VERSION}.tar.bz2
cd freetype-${FREETYPE_VERSION}
./configure --prefix=${BUILD} --enable-static --disable-shared --disable-dependency-tracking
make -j${JOBS}
make install
cd ${PACKAGES}

# proj4
echo '*building proj.4*'
tar xf proj-${PROJ_VERSION}.tar.gz
cd proj-${PROJ_VERSION}/nad
unzip -o ../../proj-datumgrid-${PROJ_GRIDS_VERSION}.zip
cd ../
./configure --prefix=${BUILD} --enable-static --disable-shared --disable-dependency-tracking
make -j${JOBS}
make install
cd ${PACKAGES}

# libpng
echo '*building libpng*'
tar xf libpng-${LIBPNG_VERSION}.tar.gz
cd libpng-${LIBPNG_VERSION}
./configure --prefix=${BUILD} --enable-static --disable-shared --disable-dependency-tracking
make -j${JOBS}
make install
cd ${PACKAGES}

# jpeg
echo '*building jpeg*'
tar xf jpegsrc.v${JPEG_VERSION}.tar.gz
cd jpeg-${JPEG_VERSION}
./configure --prefix=${BUILD} --enable-static --disable-shared --disable-dependency-tracking
make -j${JOBS}
make install
cd ${PACKAGES}

# tiff
echo '*building tiff*'
tar xf tiff-${LIBTIFF_VERSION}.tar.gz
cd tiff-${LIBTIFF_VERSION}
export OLD_CFLAGS=$CFLAGS
export CFLAGS="-DHAVE_APPLE_OPENGL_FRAMEWORK $CFLAGS"
./configure --prefix=${BUILD} --enable-static --disable-shared --disable-dependency-tracking \
--disable-cxx --with-jpeg-include-dir=${BUILD}/include --with-jpeg-lib-dir=${BUILD}/lib
make -j${JOBS}
make install
export CFLAGS=$OLD_CFLAGS
cd ${PACKAGES}

# sqlite
echo '*building sqlite*'
tar xf sqlite-autoconf-${SQLITE_VERSION}.tar.gz
cd sqlite-autoconf-${SQLITE_VERSION}
export OLD_CFLAGS=$CFLAGS
export CFLAGS="-DSQLITE_ENABLE_RTREE=1 $CFLAGS"
./configure --prefix=${BUILD} --enable-static --disable-shared --disable-dependency-tracking
make -j${JOBS}
make install
export CFLAGS=$OLD_CFLAGS
cd ${PACKAGES}


<<COMMENT
# gettext which provides libintl for libpq
# only need for internationalized error messages
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
echo '*building postgres for libpq client library*'
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

# 64 bit build
echo '*building postgres 64 bit*'
cd ${PACKAGES}
cd postgresql-${POSTGRES_VERSION}
./configure --prefix=${BUILD} --enable-shared \
--with-openssl --with-pam --with-krb5 --with-gssapi --with-ldap --enable-thread-safety \
--with-bonjour --with-libxml
# LD=${CC}
make -j${JOBS}
make install
cd ${PACKAGES}

<<COMMENT
	/Users/dane/projects/mapnik-packaging/osx/build/lib/libpq.5.dylib (compatibility version 5.0.0, current version 5.4.0)
	/usr/lib/libssl.0.9.8.dylib (compatibility version 0.9.8, current version 44.0.0)
	/usr/lib/libcrypto.0.9.8.dylib (compatibility version 0.9.8, current version 44.0.0)
	/System/Library/Frameworks/Kerberos.framework/Versions/A/Kerberos (compatibility version 5.0.0, current version 6.0.0)
	/System/Library/Frameworks/LDAP.framework/Versions/A/LDAP (compatibility version 1.0.0, current version 2.2.0)
	/usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 159.1.0)
COMMENT

# clear out shared libs
rm ${ROOTDIR}/build/lib/*dylib


# gdal
echo '*building gdal*'
tar xf gdal-${GDAL_VERSION}.tar.gz
cd gdal-${GDAL_VERSION}
./configure --prefix=${BUILD} --enable-static --enable-shared --disable-dependency-tracking \
--with-libtiff=${BUILD} \
--with-jpeg=${BUILD} \
--with-png=${BUILD} \
--with-static-proj4=${BUILD} \
--with-sqlite3=${BUILD} \
--with-hide-internal-symbols=no \
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
--with-vfk=no \
--with-grib=no

make -j${JOBS}
make install
cd ${PACKAGES}


# clear out shared libs
rm ${ROOTDIR}/build/lib/*dylib
