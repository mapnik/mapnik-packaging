# TODO
# postgres/postgis from source

# build notes for compiling mapnik deps statically
# and "FAT" (aka. universal) in order to allow
# linking a fully standalone libmapnik.a


# ICU
# icucore headers - temporary workaround until I can get more recent icu versions working
#wget http://www.opensource.apple.com/tarballs/ICU/ICU-400.38.tar.gz
#tar xvf ICU-400.38.tar.gz
#cd ICU-400.38
#make install
#cp -R build/usr/local/include/unicode/ ../../sources/include/unicode
#cd ../

tar xvf icu4c-${ICU_VERSION2)-src.tgz
export CPPFLAGS="-DU_CHARSET_IS_UTF8=1"

#-DU_USING_ICU_NAMESPACE=0
# -DU_NO_DEFAULT_INCLUDE_UTF_HEADERS=1
#-DUNISTR_FROM_CHAR_EXPLICIT=explicit -DUNISTR_FROM_STRING_EXPLICIT=explicit
export CXXFLAGS=$CFLAGS
cd icu/source
./configure --prefix=${BUILD} \
--disable-samples \
--enable-static \
--enable-release \
--disable-shared \
--with-library-bits=64 \
--with-data-packaging=archive \
--disable-icuio \
--disable-tests \
--disable-layout \
--disable-extras \
--enable-rpath

--with-library-suffix=iculib

svn co http://source.icu-project.org/repos/icu/icu/trunk/source/ icu4c-trunk
mkdir icubuild
cd icubuild
../icu4c-trunk/configure --prefix=/opt/icu49/ \
--enable-static \
--enable-release \
--disable-shared \
--with-library-bits=64 \
--with-data-packaging=archive \
--disable-threads \
--disable-samples \
--disable-icuio \
--disable-tests \
--disable-layout \
--disable-extras \
--enable-rpath

make install -k -i

make -j6 && make install

# boost
tar xjvf boost_${BOOST_VERSION2}.tar.bz2
cd boost_${BOOST_VERSION2}
./bootstrap.sh

./bjam --prefix=${BUILD} -j2 -d2 \
  --with-thread \
  --with-filesystem \
  --disable-filesystem2 \
  --with-program_options --with-system --with-chrono \
  --with-regex  \
  toolset=darwin \
  macosx-version=10.6 \
  address-model=32_64 \
  architecture=x86 \
  link=static \
  variant=release \
  -sICU_PATH=${BUILD} \
  stage

./bjam --prefix=${BUILD} -j2 -d2 \
  --with-thread \
  --with-filesystem \
  --disable-filesystem2 \
  --with-program_options --with-system --with-chrono \
  --with-regex \
  toolset=darwin \
  macosx-version=10.6 \
  address-model=32_64 \
  architecture=x86 \
  link=static \
  variant=release \
  -sICU_PATH=${BUILD} \
  install

./bjam --prefix=${BUILD} -j2 -d2 \
  --with-python \
  toolset=darwin \
  macosx-version=10.6 \
  address-model=32_64 \
  architecture=x86 \
  link=static \
  variant=release \
  install

cd ../





# postgis
# install postgres 9.x client from somewhere. 
# http://www.kyngchaos.com/software/postgres works nicely
# then copy the clients static libpq.a to a prioritized directory:
cp /usr/local/pgsql/lib/libpq.a osx/sources/lib/libpq.a
# then edit plugins/input/postgis/SConscript adding more libs to link to


# gdal 1.8.1



# cairo and friends

# pkg-config so we get cairo and friends configured correctly
# note: we use 0.25 because >= 0.26 no long bundles glib and we don't
# want to have to depend on an external glib dep

tar xvf pkg-config-${PKG_CONFIG_VERSION}.tar.gz
cd pkg-config-${PKG_CONFIG_VERSION}
# patch glib.h
# change line 198 to:
#      ifndef G_INLINE_FUNC inline
./configure --disable-debug --disable-dependency-tracking --prefix=${BUILD}
make -j${JOBS}
make install
cd ../

# pixman

tar xvf pixman-${PIXMAN_VERSION}.tar.gz
cd pixman-${PIXMAN_VERSION}
./configure --enable-static --disable-shared --disable-dependency-tracking --prefix=${BUILD}
make -j${JOBS}
make install
cd ../

# fontconfig

tar xvf fontconfig-${FONTCONFIG_VERSION}.tar.gz
cd fontconfig-${FONTCONFIG_VERSION}
./configure --enable-static --disable-shared --disable-dependency-tracking --prefix=${BUILD} \
    --with-freetype-config=${BUILD}/bin/freetype-config
make -j${JOBS}
make install
cd ../


# cairo

tar xvf cairo-${CAIRO_VERSION}.tar.gz
cd cairo-${CAIRO_VERSION}
# NOTE: PKG_CONFIG_PATH must be correctly set by this point
export LDFLAGS="-L${BUILD}/lib "$CORE_LDFLAGS
export CFLAGS="-I${BUILD}/include "$CORE_CFLAGS
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
  --enable-trace=no \
  --enable-gtk-doc=no \
  --enable-qt=no \
  --enable-quartz=no \
  --enable-quartz-font=no \
  --enable-quartz-image=no \
  --enable-win32=no \
  --enable-win32-font=no \
  --enable-skia=no \
  --enable-os2=no \
  --enable-beos=no \
  --enable-drm=no \
  --enable-drm-xr=no \
  --enable-gallium=no \
  --enable-gl=no \
  --enable-directfb=no \
  --enable-vg=no \
  --enable-egl=no \
  --enable-glx=no \
  --enable-wgl=no \
  --enable-test-surfaces=no \
  --enable-tee=no \
  --enable-xml=no \
  --enable-interpreter=no \
  --disable-valgrind \
  --enable-gobject=no \
  --enable-static=no \
  --enable-xlib=no \
  --enable-xlib-xrender=no \
  --enable-xcb=no \
  --enable-xlib-xcb=no \
  --enable-xcb-shm=no \
  --enable-xcb-drm=no \
  --disable-dependency-tracking \
  --prefix=${BUILD}
make -j${JOBS}
make install
cd ../

# mapnik

# config.py

CXX = 'clang++'
CC = 'clang++'
CUSTOM_CXXFLAGS = '-arch x86_64 -arch i386 -mmacosx-version-min=10.6 -isysroot /Developer/SDKs/MacOSX10.6.sdk -isystem osx/sources/include '
CUSTOM_LDFLAGS = '-Wl,-search_paths_first -arch x86_64 -arch i386 -Wl,-syslibroot,/Developer/SDKs/MacOSX10.6.sdk -Losx/sources/lib '
RUNTIME_LINK = 'static'
INPUT_PLUGINS = 'csv,gdal,ogr,postgis,shape,sqlite'
DESTDIR = './osx/sources/'
PATH = './osx/sources/bin/'
BOOST_INCLUDES = 'osx/sources/include'
BOOST_LIBS = 'osx/sources/lib'
FREETYPE_CONFIG = './osx/sources/bin/freetype-config'
ICU_INCLUDES = './osx/sources/include'
ICU_LIB_NAME = 'icucore'
PNG_INCLUDES = './osx/sources/include'
PNG_LIBS = './osx/sources/lib'
JPEG_INCLUDES = './osx/sources/include'
JPEG_LIBS = './osx/sources/lib'
TIFF_INCLUDES = './osx/sources/include'
TIFF_LIBS = './osx/sources/lib'
PROJ_INCLUDES = './osx/sources/include'
PROJ_LIBS = './osx/sources/lib'
PKG_CONFIG_PATH = './osx/sources/lib/pkgconfig'
SQLITE_INCLUDES = './osx/sources/include'
SQLITE_LIBS = './osx/sources/lib'
BINDINGS = 'none'


# fixup the mapnik-config
# we need to remove the local paths so that 'other-libs' and 'other-includes' look something like:

other_libs='-Wl,-search_paths_first -arch x86_64 -arch i386 -Wl,-syslibroot,/Developer/SDKs/MacOSX10.6.sdk -L/usr/lib -lfreetype -licucore -lboost_filesystem -lboost_regex -lcairomm-1.0 -lcairo -lboost_thread -lboost_system'

other_includes='-arch x86_64 -arch i386 -mmacosx-version-min=10.6 -isysroot /Developer/SDKs/MacOSX10.6.sdk -arch x86_64 -arch i386 -mmacosx-version-min=10.6 -isysroot /Developer/SDKs/MacOSX10.6.sdk -DU_HIDE_DRAFT_API -DUDISABLE_RENAMING -DHAVE_JPEG -ansi -Wall -ftemplate-depth-200 -DDARWIN -DBOOST_SPIRIT_THREADSAFE -DMAPNIK_THREADSAFE -O3 -finline-functions -Wno-inline -DNDEBUG -DHAVE_CAIRO -I/usr/include/libxml2 -DHAVE_CAIRO -DLIBTOOL_SUPPORTS_ADVISE'

