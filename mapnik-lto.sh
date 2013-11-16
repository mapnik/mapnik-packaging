sudo apt-get install linux-headers-server linux-image-server linux-server

sudo mkdir /opt/
sudo chown mapnik -R /opt/

sudo apt-get update
sudo apt-get upgrade
sudo apt-get install binutils-gold subversion build-essential gcc-multilib
mkdir -p $HOME/deb
cd $HOME/deb
apt-get source binutils
cd ~/src

# http://llvm.org/docs/GoldPlugin.html
sudo apt-get install cvs texinfo bison flex
cvs -z 9 -d :pserver:anoncvs@sourceware.org:/cvs/src login
{enter "anoncvs" as the password}
cvs -z 9 -d :pserver:anoncvs@sourceware.org:/cvs/src co binutils
mv src/ binutils
cd binutils
export CFLAGS="-O2 -I$PREFIX/include"
export CXXFLAGS="-O2 -I$PREFIX/include"
export LDFLAGS="-O2 -L$PREFIX/lib"
export CC="gcc"
export CXX="g++"
export AR=ar
export NM=nm

vim binutils/ar.c
# grep for bfd_plugin_set_plugin
# change:
bfd_plugin_set_plugin (optarg);
# to:
bfd_plugin_set_plugin ("/opt/llvm/lib/LLVMgold.so");

./configure --prefix=/opt/binutils --enable-gold --enable-plugins
make
make install
mv /opt/binutils/bin/ld /opt/binutils/bin/ld-old
cp /opt/binutils/bin/ld.gold /opt/binutils/bin/ld

#cp gold/ld-new /opt/binutils/x86_64-unknown-linux-gnu/bin/ld
#mv /opt/binutils/bin/nm /opt/binutils/bin/nm-old
#cp binutils/nm-new /opt/binutils/x86_64-unknown-linux-gnu/bin/nm

svn co http://llvm.org/svn/llvm-project/llvm/trunk llvm
cd llvm/tools
svn co http://llvm.org/svn/llvm-project/cfe/trunk clang
cd ..
./configure \
--prefix=/opt/llvm \
--enable-optimized \
--with-binutils-include=$HOME/src/binutils/include
make
sudo make install

PREFIX=$HOME/projects/mapnik-static-build/sources
export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig
export PATH=$PREFIX/bin:/opt/llvm/bin:/opt/binutils/bin:$PATH
export CFLAGS="-O4 -I$PREFIX/include -fPIC"
export CXXFLAGS="-O4 -I$PREFIX/include -fPIC"
export LDFLAGS="-O4 -L$PREFIX/lib"
export CC="clang -use-gold-plugin"
export CXX="clang++ -use-gold-plugin"
export LD_LIBRARY_PATH=/opt/mapnik/lib:/opt/llvm/lib:/opt/binutils/lib:$PREFIX/lib:$LD_LIBRARY_PATH
# we patch ar to send --plugins option in all cases
# so this line is commented since it will not work anyway
#export AR="ar -rc --plugin /opt/llvm/lib/LLVMgold.so"
export NM="nm --plugin /opt/llvm/lib/LLVMgold.so"
export RANLIB=/bin/true

mkdir -p $PREFIX
cd $PREFIX/../
mkdir -p deps

# make sure this works: https://gist.github.com/1283119

cd $PREFIX/../deps


# sqlite
wget http://www.sqlite.org/sqlite-autoconf-3070800.tar.gz
tar xvf sqlite-autoconf-3070800.tar.gz
cd sqlite-autoconf-3070800
export CFLAGS="-DSQLITE_ENABLE_RTREE=1 "$CFLAGS
./configure --prefix=$PREFIX --enable-static --disable-shared
make -j6
make install
cd ../

# freetype
wget http://download.savannah.gnu.org/releases/freetype/freetype-2.4.6.tar.bz2
tar xvf ../deps/freetype-2.4.6.tar.bz2
cd freetype-2.4.6
./configure --prefix=$PREFIX \
--enable-static \
--disable-shared
make -j6
make install

# proj4
wget http://download.osgeo.org/proj/proj-datumgrid-1.5.zip
# we use trunk instead for better threading support
svn co http://svn.osgeo.org/metacrs/proj/trunk/proj proj-trunk # at the time pre-release 4.8.0
cd proj-trunk/nad
unzip ../../proj-datumgrid-1.5.zip # answer [y] yo overwrite
cd ../
./configure --prefix=$PREFIX \
--no-mutex \
--enable-static \
--disable-shared 
make -j6
make install

cd ../

# zlib
wget http://zlib.net/zlib-1.2.5.tar.gz
tar xvf zlib-1.2.5.tar.gz
cd zlib-1.2.5
./configure --prefix=$PREFIX --static --64
make -j6
make install -i -k

# libpng
wget ftp://ftp.simplesystems.org/pub/libpng/png/src/libpng-1.5.5.tar.gz
tar xvf libpng-1.5.5.tar.gz
cd libpng-1.5.5
./configure --prefix=$PREFIX --with-zlib-prefix=`pwd`/../../sources/ --enable-static --disable-shared
make -j6
make install
cd ../

# libjpeg
wget http://www.ijg.org/files/jpegsrc.v8c.tar.gz
tar xvf jpegsrc.v8c.tar.gz
cd jpeg-8c
./configure --prefix=$PREFIX --enable-static --disable-shared
make -j6
make install
cd ../

# libtiff
wget http://download.osgeo.org/libtiff/tiff-3.9.5.tar.gz
tar xvf tiff-3.9.5.tar.gz
cd tiff-3.9.5
./configure --prefix=$PREFIX --enable-static --disable-shared
make -j6
make install
cd ../

wget http://download.icu-project.org/files/icu4c/4.8.1/icu4c-4_8_1-src.tgz
tar xvf icu4c-4_8_1-src.tgz
cd icu/source
./configure Linux --prefix=$PREFIX \
--with-library-bits=64 --enable-release \
make -j6
make install
cd ../../

sudo apt-get install python-dev
wget http://voxel.dl.sourceforge.net/project/boost/boost/1.47.0/boost_1_47_0.tar.bz2
tar xjvf boost_1_47_0.tar.bz2
cd boost_1_47_0
./bootstrap.sh
echo 'using clang ;' > ~/user-config.jam
./bjam -d2 \
  linkflags="$LDFLAGS" \
  cxxflags="$CXXFLAGS" \
  --prefix=$PREFIX --with-python \
  --with-thread \
  --with-filesystem \
  --with-program_options --with-system --with-chrono \
  --with-regex \
  -sHAVE_ICU=1 -sICU_PATH=$PREFIX \
  toolset=clang \
  link=static \
  variant=release \
  stage -a

./bjam \
  linkflags="$LDFLAGS" \
  cxxflags="$CXXFLAGS" \
  --prefix=$PREFIX --with-python \
  --with-thread \
  --with-filesystem \
  --with-program_options --with-system --with-chrono \
  --with-regex \
  -sHAVE_ICU=1 -sICU_PATH=$PREFIX \
  toolset=clang \
  link=static \
  variant=release \
  install

# no icu variant
./bjam --disable-icu \


# gdal 1.8.1
wget http://download.osgeo.org/gdal/gdal-1.8.1.tar.gz
tar xvf gdal-1.8.1.tar.gz
cd gdal-1.8.1

# add libdl and pthreads so that configure check against static libsqlite3
# does not blow up on: "unixDlOpen: error: undefined reference to 'dlopen'"
# and "undefined reference to 'pthread_mutexattr_init'"
export LDFLAGS="-ldl -pthread $LDFLAGS"
# or --unresolved-symbols=ignore-all

./configure --prefix=$PREFIX --enable-static --disable-shared \
--with-libtiff=$PREFIX \
--with-jpeg=$PREFIX \
--with-png=$PREFIX \
--with-static-proj4=$PREFIX \
--with-sqlite3=$PREFIX \
--with-spatialite=no \
--with-curl=no \
--with-geos=no \
--with-pcraster=no \
--with-cfitsio=no \
--with-odbc=no \
--with-libkml=no \
--with-pcidsk=no \
--with-jasper=no \
--with-gif=no \
--with-pg=no \
--with-vfk=no \
--with-grib=no

# note: --with-hide-internal-symbols=yes  will break during linking of ogr.input..
llvm-ld: error: Cannot link in module '/home/mapnik/projects/mapnik-static-build/sources/lib/libgdal.a(ogrfeature.o)': Linking globals named '_ZNSt6vectorIiSaIiEE13_M_insert_auxEN9__gnu_cxx17__normal_iteratorIPiS1_EERKi': symbols have different visibilities!
llvm-ld: error: Cannot link archive '/home/mapnik/projects/mapnik-static-build/sources/lib/libgdal.a'

GDAL is now configured for x86_64-unknown-linux-gnu

  Installation directory:    /home/mapnik/projects/mapnik-static-build/sources
  C compiler:                clang -use-gold-plugin -O4 -I/home/mapnik/projects/mapnik-static-build/sources/include -fPIC
  C++ compiler:              clang++ -use-gold-plugin -O4 -I/home/mapnik/projects/mapnik-static-build/sources/include -fPIC

  LIBTOOL support:           yes

  LIBZ support:              external
  LIBLZMA support:           no
  GRASS support:             no
  CFITSIO support:           no
  PCRaster support:          no
  NetCDF support:            no
  LIBPNG support:            external
  LIBTIFF support:           external (BigTIFF=no)
  LIBGEOTIFF support:        internal
  LIBJPEG support:           external
  8/12 bit JPEG TIFF:        no
  LIBGIF support:            no
  OGDI support:              no
  HDF4 support:              no
  HDF5 support:              no
  Kakadu support:            no
  JasPer support:            no
  OpenJPEG support:          no
  ECW support:               no
  MrSID support:             no
  MrSID/MG4 Lidar support:   no
  MSG support:               no
  GRIB support:              no
  EPSILON support:           no
  cURL support (wms/wcs/...):no
  PostgreSQL support:        no
  MySQL support:             no
  Ingres support:            no
  Xerces-C support:          no
  NAS support:               no
  Expat support:             yes
  Google libkml support:     no
  ODBC support:              no
  PGeo support:              no
  PCIDSK support:            old
  OCI support:               no
  GEORASTER support:         no
  SDE support:               no
  Rasdaman support:          no
  DODS support:              no
  SQLite support:            yes
  SpatiaLite support:        no
  DWGdirect support          no
  INFORMIX DataBlade support:no
  GEOS support:              no
  VFK support:               no
  Poppler support:           no
  OpenCL support:            no


  SWIG Bindings:          no

  Statically link PROJ.4:    yes
  enable OGR building:       yes
  enable pthread support:    yes
  hide internal symbols:     no

make -j6
make install
cd ../