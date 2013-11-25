#!/bin/bash
set -e -u

mkdir -p ${PACKAGES}
cd ${PACKAGES}

# icu
${ROOTDIR}/scripts/build_icu.sh

# boost
${ROOTDIR}/scripts/build_boost.sh

# bzip2
${ROOTDIR}/scripts/build_bzip2.sh

# zlib
${ROOTDIR}/scripts/build_zlib.sh

# freetype
${ROOTDIR}/scripts/build_freetype.sh

# harfbuzz
${ROOTDIR}/scripts/build_harfbuzz.sh

# jpeg
${ROOTDIR}/scripts/build_jpeg.sh

# libpng
echo '*building libpng*'
${ROOTDIR}/scripts/build_png.sh

# libxml2
${ROOTDIR}/scripts/build_libxml2.sh