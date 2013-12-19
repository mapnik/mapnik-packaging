#!/bin/bash
set -e -u -x

LICENSES=${ROOTDIR}/installer/pkg/licenses
mkdir -p ${LICENSES}

# icu
mkdir -p ${LICENSES}/icu/
cp ${PACKAGES}/icu/license.html ${LICENSES}/icu/
cp ${PACKAGES}/icu/unicode-license.txt ${LICENSES}/icu/

# boost
mkdir -p ${LICENSES}/boost/
cp ${PACKAGES}/boost_${BOOST_VERSION2}/LICENSE_1_0.txt ${LICENSES}/boost/


# freetype2
mkdir -p ${LICENSES}/freetype/
cp ${PACKAGES}/freetype-${FREETYPE_VERSION}/docs/LICENSE.TXT ${LICENSES}/freetype/

# proj4
mkdir -p ${LICENSES}/proj4/
cp ${PACKAGES}/proj-${PROJ_VERSION}/COPYING ${LICENSES}/proj4/

# libpng
mkdir -p ${LICENSES}/libpng/
cp ${PACKAGES}/libpng-${LIBPNG_VERSION}/LICENSE ${LICENSES}/libpng/

# libjpeg
mkdir -p ${LICENSES}/jpeg/
cp ${PACKAGES}/jpeg-${JPEG_VERSION}/coderules.txt ${LICENSES}/jpeg/

# libtiff
mkdir -p ${LICENSES}/tiff/
cp ${PACKAGES}/tiff-${LIBTIFF_VERSION}/COPYRIGHT ${LICENSES}/tiff/

# sqlite
mkdir -p ${LICENSES}/sqlite3/
cp ${PACKAGES}/sqlite-autoconf-${SQLITE_VERSION}/INSTALL ${LICENSES}/sqlite3/

# gettext
mkdir -p ${LICENSES}/gettext/
cp ${PACKAGES}/gettext-${GETTEXT_VERSION}/COPYING ${LICENSES}/gettext/

# postgres
mkdir -p ${LICENSES}/postgres/
cp ${PACKAGES}/postgresql-${POSTGRES_VERSION}/COPYRIGHT ${LICENSES}/postgres/

# gdal
mkdir -p ${LICENSES}/gdal/
cp ${PACKAGES}/gdal-${GDAL_VERSION}/LICENSE.TXT ${LICENSES}/gdal/

# gdal
mkdir -p ${LICENSES}/gdal/
cp ${PACKAGES}/gdal-${GDAL_VERSION}/LICENSE.TXT ${LICENSES}/gdal/
