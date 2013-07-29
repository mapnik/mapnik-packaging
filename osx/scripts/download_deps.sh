set -e
mkdir -p ${PACKAGES}
mkdir -p ${BUILD}
mkdir -p ${BUILD}/lib
mkdir -p ${BUILD}/include
cd ${PACKAGES}

function download {
    if [ ! -f $1 ]; then
        echo downloading $1
        curl -s -S -f -O  ${S3_BASE}/$1
    else
        echo using cached $1
    fi
}

# build deps
download xz-${XZ_VERSION}.tar.bz2
download nose-${NOSE_VERSION}.tar.gz
echo distribute_setup.py
curl -s -S -f -O http://python-distribute.org/distribute_setup.py

# core deps
download bzip2-${BZIP2_VERSION}.tar.gz
download jpegsrc.v${JPEG_VERSION}.tar.gz
download libpng-${LIBPNG_VERSION}.tar.gz
download zlib-${ZLIB_VERSION}.tar.gz
download libxml2-${LIBXML2_VERSION}.tar.gz
download icu4c-${ICU_VERSION2}-src.tgz
download boost_${BOOST_VERSION2}.tar.bz2
download freetype-${FREETYPE_VERSION}.tar.bz2

# protobuf
download protobuf-${PROTOBUF_VERSION}.tar.bz2

# optional deps
download tiff-${LIBTIFF_VERSION}.tar.gz
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
