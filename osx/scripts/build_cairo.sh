#!/usr/bin/env bash
set -e -u
set -o pipefail
mkdir -p ${PACKAGES}
cd ${PACKAGES}

ensure_xz

# cairo
download cairo-${CAIRO_VERSION}.tar.xz

echoerr '*building cairo*'
rm -rf cairo-${CAIRO_VERSION}
rm -rf cairo-${CAIRO_VERSION}.tar
xz -d -k cairo-${CAIRO_VERSION}.tar.xz
tar xf cairo-${CAIRO_VERSION}.tar
cd cairo-${CAIRO_VERSION}
CFLAGS="${CFLAGS} -Wno-enum-conversion -I${BUILD}/include/pixman-1"
LDFLAGS="-lfreetype -lpng -lpixman-1"
# patch cairo to avoid needing pkg-config as a build dep
patch -N -p1 < ${PATCHES}/cairo-1.12.16.diff || true
# NOTE: PKG_CONFIG_PATH must be correctly set by this point
#png_CFLAGS="-I${BUILD}/include"
#png_LIBS="-I${BUILD}/lib -lpng"
#pixman_CFLAGS="-I${BUILD}/include/pixman-1"
#pixman_LIBS="-I${BUILD}/lib -lpixman-1"
#freetype_CFLAGS="-I${BUILD}/include/"
#freetype_LIBS="-I${BUILD}/lib -lfreetype"
./autogen.sh \
  --enable-static --disable-shared \
  --enable-pdf=yes \
  --enable-ft=yes \
  --enable-png=yes \
  --enable-svg=yes \
  --enable-ps=yes \
  --enable-fc=no \
  --enable-script=no \
  --enable-interpreter=no \
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
  --enable-full-testing=no \
  --enable-symbol-lookup=no \
  --disable-dependency-tracking \
  --prefix=${BUILD}
set +e
# try to avoid: make[6]: [install-data-local] Error 1 (ignored)
$MAKE -j${JOBS} -i -k
$MAKE install -i -k
set -e
cd ${PACKAGES}