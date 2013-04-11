set -e
mkdir -p ${PACKAGES}
mkdir -p ${BUILD}
mkdir -p ${BUILD}/lib
mkdir -p ${BUILD}/include
cd ${PACKAGES}

# build deps
curl -O ${S3_BASE}/xz-${XZ_VERSION}.tar.bz2
curl -O http://pypi.python.org/packages/source/n/nose/nose-${NOSE_VERSION}.tar.gz
curl -O http://python-distribute.org/distribute_setup.py

# core deps
curl -O ${S3_BASE}/bzip2-${BZIP2_VERSION}.tar.gz
curl -O ${S3_BASE}/libpng-${LIBPNG_VERSION}.tar.gz
curl -O ${S3_BASE}/zlib-${ZLIB_VERSION}.tar.gz
curl -O ${S3_BASE}/libxml2-${LIBXML2_VERSION}.tar.gz
curl -O ${S3_BASE}/icu4c-${ICU_VERSION2}-src.tgz
curl -O ${S3_BASE}/boost_${BOOST_VERSION2}.tar.bz2
curl -O ${S3_BASE}/freetype-${FREETYPE_VERSION}.tar.bz2

