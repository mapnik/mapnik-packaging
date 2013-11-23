#!/bin/bash
set -e -u

mkdir -p ${PACKAGES}
cd ${PACKAGES}

# build dep for untarring cairo
# we build here to avoid the liblzma.dylib from being nuked earlier when we clear out gdal dylibs
echo '*building xz*'
rm -rf xz-5.0.3
tar xf xz-5.0.3.tar.bz2
cd xz-5.0.3
./configure --prefix=${BUILD}
make -j$JOBS
make install
cd ${PACKAGES}

# cairo
echo '*building cairo*'
rm -rf cairo-${CAIRO_VERSION}
rm -rf cairo-${CAIRO_VERSION}.tar
xz -d -k cairo-${CAIRO_VERSION}.tar.xz
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
