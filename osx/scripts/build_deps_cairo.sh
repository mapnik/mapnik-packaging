set -e 

cd ${PACKAGES}

echo '*building pkg-config*'
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
--disable-dependency-tracking --prefix=${BUILD}
make -j${JOBS}
make install
cd ${PACKAGES}

<<COMMENT
/Developer/usr/bin/clang -DHAVE_CONFIG_H -I. -I.. -I../pixman -I../pixman -I/Users/dane/projects/mapnik-packaging/osx/build/include/libpng15    -DU_CHARSET_IS_UTF8=1  -I/Users/dane/projects/mapnik-packaging/osx/build/include -O3 -arch x86_64 -D_FILE_OFFSET_BITS=64 -mmacosx-version-min=10.6 -isysroot /Developer/SDKs/MacOSX10.6.sdk -Wall -fno-strict-aliasing -fvisibility=hidden -D_REENTRANT -c lowlevel-blt-bench.c
  CCLD   libutils.la
  CCLD   a1-trap-test
  CCLD   pdf-op-test
  CCLD   region-test
  CCLD   region-translate-test
Undefined symbols for architecture x86_64:
  "_lcg_seed", referenced from:
      _main in region-test.o
ld: symbol(s) not found for architecture x86_64
clang: error: linker command failed with exit code 1 (use -v to see invocation)
make[2]: *** [region-test] Error 1
COMMENT

# fontconfig
echo '*building fontconfig*'
rm -rf fontconfig-${FONTCONFIG_VERSION}
tar xf fontconfig-${FONTCONFIG_VERSION}.tar.gz
cd fontconfig-${FONTCONFIG_VERSION}
./configure --enable-static --disable-shared --disable-dependency-tracking --prefix=${BUILD} \
    --with-freetype-config=${BUILD}/bin/freetype-config
make -j${JOBS}
make install
cd ${PACKAGES}


# cairo
echo '*building cairo*'
rm -rf cairo-${CAIRO_VERSION}
tar xf cairo-${CAIRO_VERSION}.tar.gz
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
  --enable-ps=no \
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
cd ${PACKAGES}


# libsigcxx
echo '*building libsigcxx*'
rm -rf libsigc++-${SIGCPP_VERSION2}
tar xf libsigc++-${SIGCPP_VERSION2}.tar.bz2
cd libsigc++-${SIGCPP_VERSION2}
./configure --enable-static --disable-shared --disable-dependency-tracking --prefix=${BUILD}
make -j${JOBS}
make install
cd ${PACKAGES}

# cairomm
echo '*building cairomm*'
rm -rf cairomm-${CAIROMM_VERSION}
tar xf cairomm-${CAIROMM_VERSION}.tar.gz
cd cairomm-${CAIROMM_VERSION}
# NOTE: PKG_CONFIG_PATH must be correctly set by this point
export LDFLAGS="-L${BUILD}/lib -lcairo -lfontconfig -lsigc-2.0 "$CORE_LDFLAGS
export CFLAGS="-I${BUILD}/include -I${BUILD}/include/cairo -I${BUILD}/include/freetype2 -I${BUILD}/include/fontconfig -I${BUILD}/lib/sigc++-2.0/include -I${BUILD}/include/sigc++-2.0 -I${BUILD}/include/sigc++-2.0/sigc++ "$CORE_CFLAGS
export CXXFLAGS="-I${BUILD}/include "$CFLAGS

./configure --enable-static --disable-shared \
    --disable-dependency-tracking --prefix=${BUILD}
make -j${JOBS}
make install
cd ${PACKAGES}

# pycairo
echo '*building pycairo*'
tar xf py2cairo-${PY2CAIRO_VERSION}.tar.bz2
cd py2cairo-${PY2CAIRO_VERSION}
# apply patch
patch wscript < ${ROOTDIR}/patches/py2cairo-static.diff
for i in {"2.6","2.7"}
do
    python$i ./waf configure --prefix=${BUILD} --nopyc --nopyo
    python$i ./waf install
done
