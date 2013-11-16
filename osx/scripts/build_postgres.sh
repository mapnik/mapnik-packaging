set -e 

mkdir -p ${PACKAGES}
cd ${PACKAGES}

: '
# gettext which provides libintl for libpq
# only need for internationalized error messages
tar xf gettext-${GETTEXT_VERSION}.tar.gz
cd gettext-${GETTEXT_VERSION}
./configure --prefix=${BUILD} --enable-static --disable-shared --disable-dependency-tracking \
--without-included-gettext --disable-debug --without-included-glib \
--without-included-libcroco  --without-included-libxml \
--without-emacs --without-git --without-cvs
make -j${JOBS}
make install
cd ${PACKAGES}
'

# postgres
echo '*building postgres for libpq client library*'

: '
postgres/INSTALL has:
       Client-only installation: If you want to install only the client
       applications and interface libraries, then you can use these
       commands:
gmake -C src/bin install
gmake -C src/include install
gmake -C src/interfaces install
gmake -C doc install
'

# 64 bit build
echo '*building postgres 64 bit*'
cd ${PACKAGES}
rm -rf postgresql-${POSTGRES_VERSION}
tar xf postgresql-${POSTGRES_VERSION}.tar.bz2
cd postgresql-${POSTGRES_VERSION}
./configure --prefix=${BUILD} --enable-shared \
--with-openssl --with-pam --with-krb5 --with-gssapi --with-ldap --enable-thread-safety \
--with-bonjour --without-libxml --without-readline
# LD=${CC}
# TODO - linking problems for unknown reasons...
set +e
make -j${JOBS} -i -k
make install -i -k
set -e
cd ${PACKAGES}

check_and_clear_libs
