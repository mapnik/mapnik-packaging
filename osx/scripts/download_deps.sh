set -e
cd ${PACKAGES}
S3_BASE="http://mapnik.s3.amazonaws.com/deps"

# build deps
wget ${S3_BASE}/xz-5.0.3.tar.bz2
wget http://pypi.python.org/packages/source/n/nose/nose-1.2.1.tar.gz
wget http://python-distribute.org/distribute_setup.py

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

