

: '

download gettext-${GETTEXT_VERSION}.tar.gz

# gettext which provides libintl for libpq
# only need for internationalized error messages
tar xf gettext-${GETTEXT_VERSION}.tar.gz
cd gettext-${GETTEXT_VERSION}
./configure --prefix=${BUILD} --enable-static --disable-shared --disable-dependency-tracking \
--without-included-gettext --disable-debug --without-included-glib \
--without-included-libcroco  --without-included-libxml \
--without-emacs --without-git --without-cvs
$MAKE -j${JOBS}
$MAKE install
cd ${PACKAGES}


'