#!/bin/bash
set -e -u
set -o pipefail
echo '...packaging binary tarball'

rm -rf ${BUILD}/var/
rm -rf ${BUILD}/share/man/

ensure_s3cmd

if [ ${TRAVIS_SECURE_ENV_VARS:-false} = true ]; then
    TARBALL_NAME="out-${TRAVIS_BUILD_ID}.tar.bz2"
else
    TARBALL_NAME="out.tar.bz2"
fi

if [ -d ${MAPNIK_DESTDIR} ]; then
    tar cjf ${TARBALL_NAME} ${BUILD}/ ${MAPNIK_DESTDIR}/
else
    tar cjf ${TARBALL_NAME} ${BUILD}/
fi

s3cmd put --acl-public ${TARBALL_NAME} s3://mapbox-springmeyer/
