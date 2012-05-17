# EXPERIMENTAL - not for normal use!

# In the rare case you want to compile mapnik
# and deps statically on linux these notes are
# a stab at automating this on Ubuntu

# tested on ubuntu 110.10 running with 4 GB
# as guest within VirtualBox using OSX 10.7 Host 

# this is intended to run as sudo

# here we go...
SRC=/usr/local/src
PREFIX=$SRC/mapnik-sdk
MAPNIK_PREFIX=/opt/mapnik
DEPS=$PREFIX/../deps
mkdir -p $DEPS
mkdir -p $MAPNIK_PREFIX
cd $DEPS
JOBS=2

export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig
export PATH=$MAPNIK_PREFIX/bin:$PREFIX/bin:$PATH
export PYTHONPATH=$MAPNIK_PREFIX/lib/python2.7/site-packages:$PYTHONPATH
export CFLAGS="-O3 -I$PREFIX/include -fPIC -Wno-unused-but-set-variable "
export CXXFLAGS="-O3 -I$PREFIX/include -fPIC -Wno-unused-but-set-variable "
export LDFLAGS="-O3 -L$PREFIX/lib "
export LD_LIBRARY_PATH=$MAPNIK_PREFIX/lib:$PREFIX/lib:$LD_LIBRARY_PATH

apt-get -y update
apt-get -y upgrade
apt-get -y install linux-headers-server linux-image-server linux-server
apt-get -y install git subversion build-essential python-dev python-nose curl

# sqlite
wget http://www.sqlite.org/sqlite-autoconf-3071200.tar.gz
tar xvf sqlite-autoconf-3071200.tar.gz
cd sqlite-autoconf-3071200
export CFLAGS="-DSQLITE_ENABLE_RTREE=1 "$CFLAGS
./configure --prefix=$PREFIX --enable-static --disable-shared
make -j$JOBS
make install
cd $DEPS

# freetype
wget http://download.savannah.gnu.org/releases/freetype/freetype-2.4.9.tar.bz2
tar xvf ../deps/freetype-2.4.9.tar.bz2
cd freetype-2.4.9
./configure --prefix=$PREFIX \
--enable-static \
--disable-shared
make -j$JOBS
make install
cd $DEPS

# proj4
wget http://download.osgeo.org/proj/proj-datumgrid-1.5.zip
wget http://download.osgeo.org/proj/proj-4.8.0.tar.gz
tar xf proj-4.8.0.tar.gz
cd proj-4.8.0/nad
unzip -o ../../proj-datumgrid-1.5.zip
cd ../
./configure --prefix=$PREFIX \
--without-mutex \
--enable-static \
--disable-shared 
make -j$JOBS
make install
cd $DEPS

# zlib
wget http://zlib.net/zlib-1.2.7.tar.gz
tar xvf zlib-1.2.7.tar.gz
cd zlib-1.2.7
./configure --prefix=$PREFIX --static --64
make -j$JOBS
make install
cd $DEPS

# libpng
wget ftp://ftp.simplesystems.org/pub/libpng/png/src/libpng-1.5.10.tar.gz
tar xvf libpng-1.5.10.tar.gz
cd libpng-1.5.10
./configure --prefix=$PREFIX --with-zlib-prefix=$PREFIX --enable-static --disable-shared
make -j$JOBS
make install
cd $DEPS

# libjpeg
wget http://www.ijg.org/files/jpegsrc.v8d.tar.gz
tar xvf jpegsrc.v8d.tar.gz
cd jpeg-8d
./configure --prefix=$PREFIX --enable-static --disable-shared
make -j$JOBS
make install
cd $DEPS

# libtiff
wget http://download.osgeo.org/libtiff/tiff-3.9.6.tar.gz
tar xvf tiff-3.9.6.tar.gz
cd tiff-3.9.6
./configure --prefix=$PREFIX --enable-static --disable-shared
make -j$JOBS
make install
cd $DEPS

#TODO - switch to static
wget http://download.icu-project.org/files/icu4c/49.1.1/icu4c-49_1_1-src.tgz
tar xvf icu4c-49_1_1-src.tgz
cd icu/source
#./configure --prefix=$PREFIX \
#--with-library-bits=64 --enable-release \
./configure --prefix=$PREFIX --disable-samples --enable-static \
--enable-release --disable-shared --with-library-bits=64 \
--with-data-packaging=archive --disable-icuio --disable-tests --disable-layout \
--disable-extras \
--enable-rpath
# icu.dat will go into: /usr/local/src/mapnik-sdk/share/icu/4.8.1.1
make -j$JOBS
make install
cd $DEPS


wget http://voxel.dl.sourceforge.net/project/boost/boost/1.49.0/boost_1_49_0.tar.bz2
tar xjvf boost_1_49_0.tar.bz2
cd boost_1_49_0
./bootstrap.sh
# problems with icu configure check?
# cat bin.v2/config.log
# iculink does not work since it comes after first start/end group
#   -sICU_LINK="-Wl,--start-group -Wl,-L$PREFIX/lib -Wl,-Bstatic -licudata -Wl,-Bstatic -licuuc -Wl,-ldl -Wl,--end-group" \

./bjam -d2 \
  linkflags="$LDFLAGS -L$PREFIX/lib -Bstatic -licudata -Bstatic -licuuc -Bdynamic -ldl" \
  cxxflags="$CXXFLAGS -DU_STATIC_IMPLEMENTATION=1" \
  --prefix=$PREFIX --with-python \
  --with-thread \
  --with-filesystem \
  --with-program_options --with-system --with-chrono \
  --with-regex \
  -sHAVE_ICU=1 -sICU_PATH=$PREFIX \
  toolset=gcc \
  link=static \
  variant=release \
  stage -a

./bjam -d2 \
  linkflags="$LDFLAGS -L$PREFIX/lib -Bstatic -licudata -Bstatic -licuuc -Bdynamic -ldl" \
  cxxflags="$CXXFLAGS -DU_STATIC_IMPLEMENTATION=1" \
  --prefix=$PREFIX --with-python \
  --with-thread \
  --with-filesystem \
  --with-program_options --with-system --with-chrono \
  --with-regex \
  -sHAVE_ICU=1 -sICU_PATH=$PREFIX \
  toolset=gcc \
  link=static \
  variant=release \
  install

cd $DEPS

# ltdl
wget http://mirror.anl.gov/pub/gnu/libtool/libtool-2.4.2.tar.gz
tar xvf libtool-2.4.2.tar.gz
cd libtool-2.4.2
./configure --prefix=$PREFIX --enable-static --disable-shared
make -j$JOBS
make install
cd $DEPS

# libxml2
wget ftp://xmlsoft.org/libxml2/libxml2-2.7.8.tar.gz
tar xvf libxml2-2.7.8.tar.gz
cd libxml2-2.7.8
./configure --prefix=$PREFIX --enable-static --disable-shared
make -j$JOBS
make install
cd $DEPS


# gdal 1.8.1
wget http://download.osgeo.org/gdal/gdal-1.9.0.tar.gz
tar xvf gdal-1.9.0.tar.gz
cd gdal-1.9.0

./configure --prefix=$PREFIX --enable-static --disable-shared \
--with-libtiff=$PREFIX \
--with-jpeg=$PREFIX \
--with-png=$PREFIX \
--with-static-proj4=$PREFIX \
--with-sqlite3=no \
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
make -j$JOBS
make install
cd $DEPS

# mapnik
# http://www.trilithium.com/johan/2005/06/static-libstdc/
# CUSTOM_CXXFLAGS="-static-libstdc++ -static-libgcc" \
# CXX="g++ -L$PREFIX/lib -Bstatic -lboost_regex -Bstatic -licudata -Bstatic -licuuc" \
#-DU_STATIC_IMPLEMENTATION=1 -DBOOST_ALL_NO_LIB=1 -DBOOST_HAS_ICU=1
cd $DEPS/../
git clone git://github.com/mapnik/mapnik.git mapnik
cd mapnik
python scons/scons.py RUNTIME_LINK=static \
INPUT_PLUGINS=gdal,ogr,osm,postgis,raster,shape,sqlite \
CUSTOM_CXXFLAGS="-fPIC " \
CUSTOM_LDFLAGS="" \
PREFIX=$MAPNIK_PREFIX \
PYTHON_PREFIX=$MAPNIK_PREFIX \
PATH_INSERT=$PREFIX/bin \
BOOST_INCLUDES=$PREFIX/include \
BOOST_LIBS=$PREFIX/lib \
JOBS=$JOBS configure
make && make install



# node
wget http://nodejs.org/dist/node-v0.4.12.tar.gz
tar xvf node-v0.4.12.tar.gz
cd node-v0.4.12
./configure
make && make install
cd $DEPS

# npm
curl http://npmjs.org/install.sh | sh


# tilemill
git clone git://github.com/mapbox/tilemill.git
cd tilemill

export CFLAGS="-O3 -I$PREFIX/include -fPIC -Wno-unused-but-set-variable "
export CXXFLAGS="-O3 -I$PREFIX/include -fPIC -Wno-unused-but-set-variable "
export LDFLAGS="-O3 -L$PREFIX/lib "

export CFLAGS="-I$MAPNIK_PREFIX $CFLAGS"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="-L$MAPNIK_PREFIX $LDFLAGS"

npm install


















# package
ln -s $PREFIX/share/icu/4.8.1.1/icudt48l.dat $MAPNIK_PREFIX/icudt48l.dat
mkdir -p $MAPNIK_PREFIX/share
ln -s $PREFIX/share/proj $MAPNIK_PREFIX/share/proj
ln -s $PREFIX/share/gdal $MAPNIK_PREFIX/share/gdal
tar cjfh mapnik.tar.bz2 $MAPNIK_PREFIX

# upload it
scp mapnik.tar.bz2 ubuntu@somewhere.com:/home/ubuntu/www


# download and unpack
sudo su root
mkdir -p /opt/mapnik
# http://www.apl.jhu.edu/Misc/Unix-info/tar/tar_75.html
tar -C / -xvf mapnik.tar.bz2

export PYTHONPATH=/opt/mapnik/lib/python2.7/site-packages:$PYTHONPATH
export LD_LIBRARY_PATH=/opt/mapnik/lib:$PREFIX/lib:$LD_LIBRARY_PATH
export GDAL_DATA=/opt/mapnik/share/gdal
export PROJ_LIB=/opt/mapnik/share/proj
export ICU_DATA=/opt/mapnik

# test

apt-get install -y python-nose git
git clone git://github.com/mapnik/mapnik.git mapnik
cd mapnik
make test


# messing around with failing to statically link c++ and gcc

echo '#include <string>' > lib.hpp
echo 'std::string hello();' >> lib.hpp
echo '#include "lib.hpp"' > lib.cpp
echo 'std::string hello() { return "hello world\n"; }' >> lib.cpp
echo '#include <iostream>' > test.cpp
echo '#include "lib.hpp"' >> test.cpp
echo 'int main(void) { std::cout << hello();return 0; }' >> test.cpp
g++ -o test test.cpp lib.cpp
./test

/usr/bin/ld: /usr/lib/gcc/x86_64-linux-gnu/4.6.1/libstdc++.a(ctype.o): relocation R_X86_64_32S against `vtable for std::ctype<wchar_t>' can not be used when making a shared object; recompile with -fPIC
/usr/lib/gcc/x86_64-linux-gnu/4.6.1/libstdc++.a: could not read symbols: Bad value
collect2: ld returned 1 exit status
scons: *** [src/libmapnik2.so] Error 1
scons: building terminated because of errors.

ln -s /usr/lib/gcc/x86_64-linux-gnu/4.6.1/libstdc++_pic.a `pwd`/libstdc++.a


g++ -L/usr/local/src/mapnik-sdk/lib -Bstatic -lboost_regex -Bstatic -licudata -Bstatic -licuuc -o src/libmapnik2.so -O3 -L. -L/usr/local/src/mapnik-sdk/lib  -static-libgcc -Wl,-rpath-link,. -Wl,-soname,libmapnik2.so.2.0 -shared src/libxml2_loader.os src/load_map.os src/datasource_cache.os src/feature_style_processor.os src/color.os src/box2d.os src/expression_string.os src/filter_factory.os src/feature_type_style.os src/font_engine_freetype.os src/font_set.os src/gradient.os src/graphics.os src/image_reader.os src/image_util.os src/layer.os src/line_symbolizer.os src/line_pattern_symbolizer.os src/map.os src/memory.os src/parse_path.os src/palette.os src/placement_finder.os src/plugin.os src/png_reader.os src/point_symbolizer.os src/polygon_pattern_symbolizer.os src/save_map.os src/shield_symbolizer.os src/text_symbolizer.os src/tiff_reader.os src/wkb.os src/projection.os src/proj_transform.os src/distance.os src/scale_denominator.os src/memory_datasource.os src/stroke.os src/symbolizer.os src/arrow.os src/unicode.os src/glyph_symbolizer.os src/markers_symbolizer.os src/metawriter.os src/raster_colorizer.os src/text_placements.os src/wkt/wkt_factory.os src/metawriter_inmem.os src/metawriter_factory.os src/mapped_memory_cache.os src/marker_cache.os src/svg_parser.os src/svg_path_parser.os src/svg_points_parser.os src/svg_transform_parser.os src/warp.os src/jpeg_reader.os src/agg/agg_renderer.os src/agg/process_building_symbolizer.os src/agg/process_glyph_symbolizer.os src/agg/process_line_symbolizer.os src/agg/process_line_pattern_symbolizer.os src/agg/process_text_symbolizer.os src/agg/process_point_symbolizer.os src/agg/process_polygon_symbolizer.os src/agg/process_polygon_pattern_symbolizer.os src/agg/process_raster_symbolizer.os src/agg/process_shield_symbolizer.os src/agg/process_markers_symbolizer.os deps/agg/src/agg_curves.os deps/agg/src/agg_trans_warp_magnifier.os deps/agg/src/agg_sqrt_tables.os deps/agg/src/agg_trans_double_path.os deps/agg/src/agg_rounded_rect.os deps/agg/src/agg_gsv_text.os deps/agg/src/agg_vpgen_clip_polyline.os deps/agg/src/agg_vcgen_bspline.os deps/agg/src/agg_trans_affine.os deps/agg/src/agg_vcgen_stroke.os deps/agg/src/agg_line_profile_aa.os deps/agg/src/agg_vpgen_segmentator.os deps/agg/src/agg_line_aa_basics.os deps/agg/src/agg_trans_single_path.os deps/agg/src/agg_arc.os deps/agg/src/agg_embedded_raster_fonts.os deps/agg/src/agg_bezier_arc.os deps/agg/src/agg_vcgen_dash.os deps/agg/src/agg_vcgen_markers_term.os deps/agg/src/agg_vpgen_clip_polygon.os deps/agg/src/agg_bspline.os deps/agg/src/agg_image_filters.os deps/agg/src/agg_vcgen_contour.os deps/agg/src/agg_arrowhead.os deps/agg/src/agg_vcgen_smooth_poly1.os src/grid/grid_renderer.os src/grid/process_building_symbolizer.os src/grid/process_glyph_symbolizer.os src/grid/process_line_pattern_symbolizer.os src/grid/process_line_symbolizer.os src/grid/process_markers_symbolizer.os src/grid/process_point_symbolizer.os src/grid/process_polygon_pattern_symbolizer.os src/grid/process_polygon_symbolizer.os src/grid/process_raster_symbolizer.os src/grid/process_shield_symbolizer.os src/grid/process_text_symbolizer.os -Ldeps/agg -Lsrc -L/usr/local/src/mapnik-sdk/lib -L/usr/local/lib -L/usr/lib -lfreetype -lltdl -lpng -ltiff -lz -ljpeg -lproj -licuuc -lboost_filesystem -lboost_system -lboost_regex -lxml2 -lboost_thread -licudata
