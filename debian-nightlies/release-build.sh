# release a mapnik tag on launchpad

# first create a new PPA like ppa:mapnik/v2.1.0, then run these commands
# copy boost packages over to it, if needed
# https://launchpad.net/~mapnik/+archive/boost/+copy-packages
# WARNING: only copy 2 boost packages at a time to avoid likely timeouts

GPGKEY=89DBC525
DEBFULLNAME="Dane Springmeyer (Mapnik Releases)"
DEBEMAIL="dane.springmeyer@gmail.com"
DEST="mapnik" # the launchpad account name
DISTS="saucy raring quantal precise lucid"
PACKAGE="mapnik"
BUILD_VERSION="2.1.0"
DATE_REPR=$(date -R)
SOURCE="${PACKAGE}_${BUILD_VERSION}"
ORIG_TAR="${SOURCE}.orig.tar.bz2"
PPA="ppa:${DEST}/v${BUILD_VERSION}"

mkdir deb-packaging
cd deb-packaging

wget http://mapnik.s3.amazonaws.com/dist/v${BUILD_VERSION}/mapnik-v${BUILD_VERSION}.tar.bz2
tar xf mapnik-v${BUILD_VERSION}.tar.bz2
mv mapnik-v${BUILD_VERSION} "${SOURCE}"
tar cjf "${ORIG_TAR}" "${SOURCE}/"

git clone https://github.com/mapnik/mapnik-packaging
cp -r "mapnik-packaging/debian-nightlies/master/debian" "${SOURCE}/"

CHANGELOG_NOTE="v${BUILD_VERSION} release (https://github.com/mapnik/mapnik/wiki/Release${BUILD_VERSION})"

for DIST in ${DISTS}; do
  DIST_VERSION="${BUILD_VERSION}-ubuntu1~${DIST}1";
  echo "${PACKAGE} (${DIST_VERSION}) ${DIST}; urgency=medium" > "${SOURCE}/debian/changelog"
  echo  >> "${SOURCE}/debian/changelog"
  echo "  * ${CHANGELOG_NOTE}" >> "${SOURCE}/debian/changelog"
  echo  >> "${SOURCE}/debian/changelog"
  echo " -- ${DEBFULLNAME} <${DEBEMAIL}>  ${DATE_REPR}" >> "${SOURCE}/debian/changelog"
  cd ${SOURCE};
  debuild -S -k${GPGKEY}
  dput -f "$PPA" ../*source.changes
  rm ../*ubuntu1*
  cd ../
done
