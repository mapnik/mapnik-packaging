#!/bin/bash
set -e -u -x

mkdir -p ${PACKAGES}
cd ${PACKAGES}

# icu
${ROOTDIR}/scripts/build_icu.sh

# boost
BOOST_LIBRARIES="--with-thread --with-filesystem --disable-filesystem2 --with-system --with-regex"
if [ ${BOOST_ARCH} != "arm" ]; then
    BOOST_LIBRARIES="$BOOST_LIBRARIES --with-program_options"
    # --with-chrono --with-iostreams --with-date_time --with-atomic --with-timer --with-program_options --with-test
fi

${ROOTDIR}/scripts/build_boost.sh "$BOOST_LIBRARIES"

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
${ROOTDIR}/scripts/build_png.sh

# libxml2
${ROOTDIR}/scripts/build_libxml2.sh