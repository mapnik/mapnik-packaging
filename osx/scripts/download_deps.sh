set -e
mkdir -p ${PACKAGES}
mkdir -p ${BUILD}
mkdir -p ${BUILD}/lib
mkdir -p ${BUILD}/include
cd ${PACKAGES}

# build deps
echo xz-${XZ_VERSION}
curl -s -S -f -O ${S3_BASE}/xz-${XZ_VERSION}.tar.bz2
echo nose-${NOSE_VERSION}
curl -s -S -f -O http://pypi.python.org/packages/source/n/nose/nose-${NOSE_VERSION}.tar.gz
echo distribute_setup.py
curl -s -S -f -O http://python-distribute.org/distribute_setup.py

# core deps
echo bzip2-${BZIP2_VERSION}
curl -s -S -f -O ${S3_BASE}/bzip2-${BZIP2_VERSION}.tar.gz
echo jpegsrc.v${JPEG_VERSION}
curl -s -S -f -O ${S3_BASE}/jpegsrc.v${JPEG_VERSION}.tar.gz
echo libpng-${LIBPNG_VERSION}
curl -s -S -f -O ${S3_BASE}/libpng-${LIBPNG_VERSION}.tar.gz
echo zlib-${ZLIB_VERSION}
curl -s -S -f -O ${S3_BASE}/zlib-${ZLIB_VERSION}.tar.gz
echo libxml2-${LIBXML2_VERSION}
curl -s -S -f -O ${S3_BASE}/libxml2-${LIBXML2_VERSION}.tar.gz
echo icu4c-${ICU_VERSION2}-src
curl -s -S -f -O ${S3_BASE}/icu4c-${ICU_VERSION2}-src.tgz
echo boost_${BOOST_VERSION2}
curl -s -S -f -O ${S3_BASE}/boost_${BOOST_VERSION2}.tar.bz2
echo freetype-${FREETYPE_VERSION}
curl -s -S -f -O ${S3_BASE}/freetype-${FREETYPE_VERSION}.tar.bz2

# protobuf
curl -s -S -f -O  ${S3_BASE}/protobuf-${PROTOBUF_VERSION}.tar.bz2

# optional deps
curl -s -S -f -O ${S3_BASE}/tiff-${LIBTIFF_VERSION}.tar.gz
curl -s -S -f -O ${S3_BASE}/sqlite-autoconf-${SQLITE_VERSION}.tar.gz
curl -s -S -f -O ${S3_BASE}/libgeotiff-${LIBGEOTIFF_VERSION}.tar.gz
curl -s -S -f -O ${S3_BASE}/proj-datumgrid-${PROJ_GRIDS_VERSION}.zip
curl -s -S -f -O ${S3_BASE}/proj-${PROJ_VERSION}.tar.gz
curl -s -S -f -O ${S3_BASE}/postgresql-${POSTGRES_VERSION}.tar.bz2
curl -s -S -f -O ${S3_BASE}/expat-${EXPAT_VERSION}.tar.gz
curl -s -S -f -O ${S3_BASE}/gdal-${GDAL_VERSION}.tar.gz
curl -s -S -f -O ${S3_BASE}/gettext-${GETTEXT_VERSION}.tar.gz
curl -s -S -f -O ${S3_BASE}/pkg-config-${PKG_CONFIG_VERSION}.tar.gz
curl -s -S -f -O ${S3_BASE}/pixman-${PIXMAN_VERSION}.tar.gz
curl -s -S -f -O ${S3_BASE}/fontconfig-${FONTCONFIG_VERSION}.tar.gz
curl -s -S -f -O ${S3_BASE}/cairo-${CAIRO_VERSION}.tar.xz
curl -s -S -f -O ${S3_BASE}/py2cairo-${PY2CAIRO_VERSION}.tar.bz2
curl -s -S -f -O ${S3_BASE}/pycairo-${PY3CAIRO_VERSION}.tar.bz2
