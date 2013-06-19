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
./configure --prefix=${BUILD} --without-mutex \
--enable-static --disable-shared --disable-dependency-tracking
make -j${JOBS}
make install
cd ${PACKAGES}


# tiff
echo '*building tiff*'
rm -rf tiff-${LIBTIFF_VERSION}
tar xf tiff-${LIBTIFF_VERSION}.tar.gz
cd tiff-${LIBTIFF_VERSION}
export OLD_CFLAGS=$CFLAGS
export CFLAGS="-DHAVE_APPLE_OPENGL_FRAMEWORK $CFLAGS"
./configure --prefix=${BUILD} \
--enable-static --disable-shared \
--disable-dependency-tracking \
--disable-cxx \
--enable-defer-strile-load \
--with-jpeg-include-dir=${BUILD}/include \
--with-jpeg-lib-dir=${BUILD}/lib \
--with-zlib-include-dir=${BUILD}/include \
--with-zlib-lib-dir=${BUILD}/lib \
--disable-lzma --disable-jbig --disable-mdi \
--without-x

make -j${JOBS}
make install
export CFLAGS=$OLD_CFLAGS
cd ${PACKAGES}

# sqlite
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


: '
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
'

# postgres
echo '*building postgres for libpq client library*'

: '
postgres/INSTALL has:
       Client-only installation: If you want to install only the client
       applications and interface libraries, then you can use these
       commands:
gmake -C src/bin install
gmake -C src/include install
gmake -C src/interfaces install
gmake -C doc install
'

# 64 bit build
echo '*building postgres 64 bit*'
cd ${PACKAGES}
rm -rf postgresql-${POSTGRES_VERSION}
tar xf postgresql-${POSTGRES_VERSION}.tar.bz2
cd postgresql-${POSTGRES_VERSION}
./configure --prefix=${BUILD} --enable-shared \
--with-openssl --with-pam --with-krb5 --with-gssapi --with-ldap --enable-thread-safety \
--with-bonjour --without-libxml
# LD=${CC}
# TODO - linking problems for unknown reasons...
make -j${JOBS} -i -k
make install -i -k
cd ${PACKAGES}

: '
otool -L ${BUILD}/lib/*dylib
	/Users/dane/projects/mapnik-packaging/osx/build/lib/libpq.5.dylib (compatibility version 5.0.0, current version 5.4.0)
	/usr/lib/libssl.0.9.8.dylib (compatibility version 0.9.8, current version 44.0.0)
	/usr/lib/libcrypto.0.9.8.dylib (compatibility version 0.9.8, current version 44.0.0)
	/System/Library/Frameworks/Kerberos.framework/Versions/A/Kerberos (compatibility version 5.0.0, current version 6.0.0)
	/System/Library/Frameworks/LDAP.framework/Versions/A/LDAP (compatibility version 1.0.0, current version 2.2.0)
	/usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 159.1.0)
'

# clear out shared libs
rm ${BUILD}/lib/*dylib

# geotiff
echo '*building geotiff*'
rm -rf libgeotiff-${LIBGEOTIFF_VERSION}
tar xf libgeotiff-${LIBGEOTIFF_VERSION}.tar.gz
cd libgeotiff-${LIBGEOTIFF_VERSION}
./configure --prefix=${BUILD} --enable-static --disable-shared --disable-dependency-tracking \
--with-libtiff=${BUILD} \
--with-jpeg=${BUILD} \
--with-zip=${BUILD} \
--with-proj=${BUILD}
make -j${JOBS}
make install
cd ${PACKAGES}

# expat for gdal to avoid linking against system expat in /usr/lib
echo '*building expat*'
rm -rf expat-${EXPAT_VERSION}
tar xf expat-${EXPAT_VERSION}.tar.gz
cd expat-${EXPAT_VERSION}
./configure --prefix=${BUILD} --enable-static --disable-shared
make -j${JOBS}
make install
cd ${PACKAGES}

# gdal
echo '*building gdal*'
rm -rf gdal-${GDAL_VERSION}
tar xf gdal-${GDAL_VERSION}.tar.gz
cd gdal-${GDAL_VERSION}
# http://trac.osgeo.org/gdal/wiki/BuildingOnUnixWithMinimizedDrivers
# not bigtiff check will fail…
# fix bigtiff check
patch configure ${PATCHES}/bigtiff_check.diff
./configure --prefix=${BUILD} --enable-static --enable-shared --disable-dependency-tracking \
--with-libtiff=${BUILD} \
--with-geotiff=${BUILD} \
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
--with-grib=no \
--with-freexl=no

make -j${JOBS}
# gdal 1.10 command line tools will not link, so force it since libgdal works
make install -i -k
cd ${PACKAGES}


: '
otool -L ${BUILD}/lib/*dylib
	/Users/dane/projects/mapnik-packaging/osx/build/lib/libgdal.1.dylib (compatibility version 18.0.0, current version 18.0.0)
	/usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 159.1.0)
	/usr/lib/libexpat.1.dylib (compatibility version 7.0.0, current version 7.2.0)
	/usr/lib/libz.1.dylib (compatibility version 1.0.0, current version 1.2.5)
	/usr/lib/libiconv.2.dylib (compatibility version 7.0.0, current version 7.0.0)
	/usr/lib/libstdc++.6.dylib (compatibility version 7.0.0, current version 52.0.0)
'

# clear out shared libs
rm ${BUILD}/lib/*dylib

echo '*building pkg-config*'
rm -rf pkg-config-${PKG_CONFIG_VERSION}
tar xf pkg-config-${PKG_CONFIG_VERSION}.tar.gz
cd pkg-config-${PKG_CONFIG_VERSION}
# patch glib.h
# change line 198 to:
#      ifndef G_INLINE_FUNC inline
export OLD_CFLAGS=$CFLAGS
export CFLAGS="$CFLAGS -std=gnu89"

./configure --disable-debug \
  --disable-dependency-tracking \
  --prefix=${BUILD} \
  --with-pc-path=${BUILD}/lib/pkgconfig
  
make -j${JOBS}
make install
export CFLAGS=$OLD_CFLAGS
cd ${PACKAGES}


echo '*building pixman*'
rm -rf pixman-${PIXMAN_VERSION}
tar xf pixman-${PIXMAN_VERSION}.tar.gz
cd pixman-${PIXMAN_VERSION}
./configure --enable-static --disable-shared \
--disable-dependency-tracking --prefix=${BUILD} \
--disable-mmx
make -j${JOBS} -i -k
make install -i -k
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


# cairo
echo '*building cairo*'
rm -rf cairo-${CAIRO_VERSION}
xz -d cairo-${CAIRO_VERSION}.tar.xz
tar xf cairo-${CAIRO_VERSION}.tar
cd cairo-${CAIRO_VERSION}
# NOTE: PKG_CONFIG_PATH must be correctly set by this point
export png_CFLAGS="-I${BUILD}/include"
export png_LIBS="-I${BUILD}/lib -lpng"
./configure \
  --enable-static --disable-shared \
  --enable-pdf=yes \
  --enable-ft=yes \
  --enable-png=yes \
  --enable-svg=yes \
  --enable-ps=yes \
  --enable-fc=yes \
  --enable-interpreter=yes \
  --enable-quartz=no \
  --enable-quartz-image=no \
  --enable-quartz-font=no \
  --enable-trace=no \
  --enable-gtk-doc=no \
  --enable-qt=no \
  --enable-win32=no \
  --enable-win32-font=no \
  --enable-skia=no \
  --enable-os2=no \
  --enable-beos=no \
  --enable-drm=no \
  --enable-gallium=no \
  --enable-gl=no \
  --enable-glesv2=no \
  --enable-directfb=no \
  --enable-vg=no \
  --enable-egl=no \
  --enable-glx=no \
  --enable-wgl=no \
  --enable-test-surfaces=no \
  --enable-tee=no \
  --enable-xml=no \
  --disable-valgrind \
  --enable-gobject=no \
  --enable-xlib=no \
  --enable-xlib-xrender=no \
  --enable-xcb=no \
  --enable-xlib-xcb=no \
  --enable-xcb-shm=no \
  --disable-dependency-tracking \
  --prefix=${BUILD}
make -j${JOBS}
make install
cd ${PACKAGES}

# py2cairo
echo '*building py2cairo*'
rm -rf py2cairo-${PY2CAIRO_VERSION}
tar xf py2cairo-${PY2CAIRO_VERSION}.tar.bz2
cd py2cairo-${PY2CAIRO_VERSION}
# apply patch
patch wscript < ${PATCHES}/py2cairo-static.diff
for i in {"2.6","2.7"}
do
    PYTHON=python$i ./waf configure --prefix=${BUILD} --nopyc --nopyo
    PYTHON=python$i ./waf install
done
cd ${PACKAGES}

# py3cairo
echo '*building py3cairo*'
rm -rf pycairo-${PY3CAIRO_VERSION}
tar xf pycairo-${PY3CAIRO_VERSION}.tar.bz2
cd pycairo-${PY3CAIRO_VERSION}
# apply patch
patch wscript < ${PATCHES}/py3cairo-static.diff
export PATH=/Library/Frameworks/Python.framework/Versions/3.3/bin/:$PATH
for i in {"3.3",}
do
    PYTHON=python$i ./waf configure --prefix=${BUILD} --nopyc --nopyo
    PYTHON=python$i ./waf install
done
cd ${PACKAGES}
