#!/usr/bin/env bash
set -e -u
set -o pipefail
mkdir -p ${PACKAGES}
mkdir -p ${BUILD}
mkdir -p ${BUILD}/lib
mkdir -p ${BUILD}/include
cd ${PACKAGES}

# build deps
download xz-${XZ_VERSION}.tar.bz2
download nose-${NOSE_VERSION}.tar.gz
if [ ! -f distribute_setup.py ]; then
  echoerr downloading distribute_setup.py
  curl -s -S -f -O http://python-distribute.org/distribute_setup.py
else
  echoerr using cached distribute_setup.py
fi

# core deps
download bzip2-${BZIP2_VERSION}.tar.gz
download jpegsrc.v${JPEG_VERSION}.tar.gz
download libpng-${LIBPNG_VERSION}.tar.gz
download zlib-${ZLIB_VERSION}.tar.gz
download libxml2-${LIBXML2_VERSION}.tar.gz
download icu4c-${ICU_VERSION2}-src.tgz
download boost_${BOOST_VERSION2}.tar.bz2
download freetype-${FREETYPE_VERSION}.tar.bz2
download harfbuzz-${HARFBUZZ_VERSION}.tar.bz2

# protobuf
download protobuf-${PROTOBUF_VERSION}.tar.bz2

# sparsehash
download sparsehash-${SPARSEHASH_VERSION}.tar.gz

# node.js
download node-v${NODE_VERSION}.tar.gz

# optional deps
download tiff-${LIBTIFF_VERSION}.tar.gz
download libwebp-${WEBP_VERSION}.tar.gz
download sqlite-autoconf-${SQLITE_VERSION}.tar.gz
download libgeotiff-${LIBGEOTIFF_VERSION}.tar.gz
download proj-datumgrid-${PROJ_GRIDS_VERSION}.zip
download proj-${PROJ_VERSION}.tar.gz
download postgresql-${POSTGRES_VERSION}.tar.bz2
download expat-${EXPAT_VERSION}.tar.gz
download gdal-${GDAL_VERSION}.tar.gz
download gettext-${GETTEXT_VERSION}.tar.gz
download pkg-config-${PKG_CONFIG_VERSION}.tar.gz
download pixman-${PIXMAN_VERSION}.tar.gz
download fontconfig-${FONTCONFIG_VERSION}.tar.gz
download cairo-${CAIRO_VERSION}.tar.xz
download py2cairo-${PY2CAIRO_VERSION}.tar.bz2
download pycairo-${PY3CAIRO_VERSION}.tar.bz2
download stxxl-${STXXL_VERSION}.tar.gz
