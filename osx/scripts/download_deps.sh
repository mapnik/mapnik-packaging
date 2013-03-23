set -e
cd ${PACKAGES}
S3_BASE="http://mapnik.s3.amazonaws.com/deps"

# build deps
wget ${S3_BASE}/xz-5.0.3.tar.bz2
wget http://pypi.python.org/packages/source/n/nose/nose-1.2.1.tar.gz
wget http://python-distribute.org/distribute_setup.py

export ICU_VERSION="50.1.2"
export ICU_VERSION2="50_1_2"
export BOOST_VERSION="1.53.0"
export BOOST_VERSION2="1_53_0"
export SQLITE_VERSION="3071502"
export FREETYPE_VERSION="2.4.11"
export PROJ_VERSION="4.8.0"
export PROJ_GRIDS_VERSION="1.5"
export LIBPNG_VERSION="1.5.14"
export LIBTIFF_VERSION="4.0.3"
export LIBGEOTIFF_VERSION="1.4.0"
export JPEG_VERSION="8d"
export EXPAT_VERSION="2.1.0"
export GDAL_VERSION="1.9.2"
export GETTEXT_VERSION="0.18.1.1"
export POSTGRES_VERSION="9.2.3"
export ZLIB_VERSION="1.2.7"
export LIBTOOL_VERSION="2.4.2"
export LIBXML2_VERSION="2.9.0"
export BZIP2_VERSION="1.0.6"
export PKG_CONFIG_VERSION="0.25"
export FONTCONFIG_VERSION="2.10.0"
export PIXMAN_VERSION="0.28.2"
export CAIRO_VERSION="1.12.14"
export PY2CAIRO_VERSION="1.10.0"
export PY3CAIRO_VERSION="1.10.0"

wget ${S3_BASE}/bzip2-${BZIP2_VERSION}.tar.gz
wget ${S3_BASE}/libtool-${LIBTOOL_VERSION}.tar.gz
wget ${S3_BASE}/libpng-${LIBPNG_VERSION}.tar.gz
wget ${S3_BASE}/zlib-${ZLIB_VERSION}.tar.gz
wget ${S3_BASE}/libxml2-${LIBXML2_VERSION}.tar.gz
wget ${S3_BASE}/icu4c-${ICU_VERSION2}-src.tgz
wget ${S3_BASE}/boost_${BOOST_VERSION2}.tar.bz2
wget ${S3_BASE}/sqlite-autoconf-${SQLITE_VERSION}.tar.gz
wget ${S3_BASE}/freetype-${FREETYPE_VERSION}.tar.bz2
wget ${S3_BASE}/jpegsrc.v${JPEG_VERSION}.tar.gz
wget ${S3_BASE}/tiff-${LIBTIFF_VERSION}.tar.gz
wget ${S3_BASE}/libgeotiff-${LIBGEOTIFF_VERSION}.tar.gz
wget ${S3_BASE}/proj-datumgrid-${PROJ_GRIDS_VERSION}.zip
wget ${S3_BASE}/proj-${PROJ_VERSION}.tar.gz
wget ${S3_BASE}/postgresql-${POSTGRES_VERSION}.tar.bz2
wget ${S3_BASE}/expat-${EXPAT_VERSION}.tar.gz
wget ${S3_BASE}/gdal-${GDAL_VERSION}.tar.gz
wget ${S3_BASE}/gettext-${GETTEXT_VERSION}.tar.gz
wget ${S3_BASE}/pkg-config-${PKG_CONFIG_VERSION}.tar.gz
wget ${S3_BASE}/pixman-${PIXMAN_VERSION}.tar.gz
wget ${S3_BASE}/fontconfig-${FONTCONFIG_VERSION}.tar.gz
wget ${S3_BASE}/cairo-${CAIRO_VERSION}.tar.xz
wget ${S3_BASE}/py2cairo-${PY2CAIRO_VERSION}.tar.bz2
wget ${S3_BASE}/pycairo-${PY3CAIRO_VERSION}.tar.bz2

