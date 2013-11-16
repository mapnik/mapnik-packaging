set -e 

mkdir -p ${PACKAGES}
cd ${PACKAGES}

# proj4
${ROOTDIR}/scripts/build_proj4.sh

# webp
${ROOTDIR}/scripts/build_webp.sh

# tiff
${ROOTDIR}/scripts/build_tiff.sh

# sqlite
${ROOTDIR}/scripts/build_sqlite.sh

# postgres
${ROOTDIR}/scripts/build_postgres.sh

# geotiff
${ROOTDIR}/scripts/build_geotiff.sh

# expat
${ROOTDIR}/scripts/build_expat.sh

# gdal
${ROOTDIR}/scripts/build_gdal.sh

# pkg-config
${ROOTDIR}/scripts/build_pkg_config.sh

# pkg-config
${ROOTDIR}/scripts/build_pixman.sh

# fontconfig
${ROOTDIR}/scripts/build_fontconfig.sh

# cairo
${ROOTDIR}/scripts/build_cairo.sh
