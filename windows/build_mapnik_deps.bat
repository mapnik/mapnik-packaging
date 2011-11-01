@echo off

set ROOTDIR=%CD%
set PKGDIR=%ROOTDIR%\packages
set PATH=%PATH%;c:\GnuWin32\bin
set ZLIB_VERSION=1.2.5
set LIBPNG_VERSION=1.5.5
set PIXMAN_VERSION=0.22.2
set CAIRO_VERSION=1.10.2
set BZIP2_VERSION=1.0.6
set JPEG_VERSIOB=8c
set FREETYPE_VERSION=2.4.7
set POSTGRESQL_VERSION=9.1.1
set TIFF_VERSION=4.0.0beta7
set PROJ_VERSION=4.7.0
set GDAL_VERSION=1.8.1


echo "Downloading packages ..."
if not exist %PKGDIR% mkdir %PKGDIR%
cd %PKGDIR%
if not exist "jpegsr%JPEG_VERSIOB%.zip" curl http://www.ijg.org/files/jpegsr%JPEG_VERSIOB%.zip -O
if not exist "libpng-%LIBPNG_VERSION%.tar.gz" curl ftp://ftp.simplesystems.org/pub/libpng/png/src/libpng-%LIBPNG_VERSION%.tar.gz -O
if not exist "zlib-%ZLIB_VERSION%.tar.gz" curl http://www.zlib.net/zlib-%ZLIB_VERSION%.tar.gz -O
if not exist "pixman-%PIXMAN_VERSION%.tar.gz" curl http://www.cairographics.org/releases/pixman-%PIXMAN_VERSION%.tar.gz -O
if not exist "cairo-%CAIRO_VERSION%.tar.gz" curl http://www.cairographics.org/releases/cairo-%CAIRO_VERSION%.tar.gz -O
if not exist "freetype-%FREETYPE_VERSION%.tar.gz" curl http://ftp.igh.cnrs.fr/pub/nongnu/freetype/freetype-%FREETYPE_VERSION%.tar.gz -O
if not exist "postgresql-%POSTGRESQL_VERSION%.tar.gz" curl http://ftp.de.postgresql.org/packages/databases/PostgreSQL/latest/postgresql-%POSTGRESQL_VERSION%.tar.gz -O
if not exist "proj-%PROJ_VERSION%.tar.gz" curl http://download.osgeo.org/proj/proj-%PROJ_VERSION%.tar.gz -O
if not exist "tiff-%TIFF_VERSION%.tar.gz" curl http://download.osgeo.org/libtiff/tiff-%TIFF_VERSION%.tar.gz -O
if not exist "gdal-%GDAL_VERSION%.tar.gz" curl http://download.osgeo.org/gdal/gdal-%GDAL_VERSION%.tar.gz -O
cd %ROOTDIR%

echo "Building Mapnik dependencies..."

if not exist %ROOTDIR%\postgresql (
   echo "->libpq (Postgresql client library)"
   bsdtar xvfz "%PKGDIR%\postgresql-%POSTGRESQL_VERSION%.tar.gz"
   rename postgresql-%POSTGRESQL_VERSION% postgresql
   cd postgresql\src
   nmake /f win32.mak
   cd %ROOTDIR%
)

if not exist %ROOTDIR%\freetype (
   echo "->freetype"
   bsdtar xvfz "%PKGDIR%\freetype-%FREETYPE_VERSION%.tar.gz"
   rename freetype-%FREETYPE_VERSION% freetype
   cd freetype
   vcbuild builds\win32\vc2008\freetype.vcproj "Release|Win32"
   move objs\win32\vc2008\freetype247.lib freetype.lib
   cd %ROOTDIR%
)

if not exist %ROOTDIR%\jpeg (
   echo "->jpeg"
   unzip %PKGDIR%\jpegsr%JPEG_VERSIOB%.zip
   rename jpeg-%JPEG_VERSIOB% jpeg
   cd jpeg 
   copy jconfig.txt jconfig.h
   nmake /f Makefile.vc nodebug=1
   cd %ROOTDIR%
)

if not exist %ROOTDIR%\zlib  (
   echo "->zlib"
   if not exist %ROOTDIR%\libpng (
   bsdtar xvfz %PKGDIR%\libpng-%LIBPNG_VERSION%.tar.gz
   rename libpng-%LIBPNG_VERSION% libpng
)

bsdtar xvfz %PKGDIR%\zlib-%ZLIB_VERSION%.tar.gz
rename zlib-%ZLIB_VERSION% zlib

mkdir %ROOTDIR%\zlib\projects\visualc71
cd %ROOTDIR%\zlib\projects\visualc71
copy %ROOTDIR%\libpng\projects\visualc71\zlib.vcproj .
vcbuild /upgrade zlib.vcproj
vcbuild zlib.vcproj "LIB Release"
cd %ROOTDIR%\zlib
move projects\visualc71\Win32_LIB_Release\ZLib\zlib.lib zlib.lib
cd  %ROOTDIR%
echo "->libpng"
cd %ROOTDIR%\libpng\projects\visualc71
vcbuild /upgrade libpng.vcproj
vcbuild libpng.vcproj "LIB Release"
cd %ROOTDIR%\libpng
move projects\visualc71\Win32_LIB_Release\libpng.lib libpng.lib
cd %ROOTDIR%
)

if not exist %ROOTDIR%\pixman (
   echo "->pixman"
   bsdtar xvfz %PKGDIR%\pixman-%PIXMAN_VERSION%.tar.gz
   rename pixman-%PIXMAN_VERSION% pixman
   cd pixman\pixman
   make -f Makefile.win32 "CFG=release"
   cd %ROOTDIR%
)

if not exist %ROOTDIR%\tiff (
   echo "->tiff"
   bsdtar xvfz %PKGDIR%\tiff-%TIFF_VERSION%.tar.gz
   rename tiff-%TIFF_VERSION% tiff
   cd tiff
   set P1=s/\^#JPEG_SUPPORT.*/JPEG_SUPPORT = 1/;
   set P2=s/\^#JPEGDIR.*/JPEGDIR = %ROOTDIR:\=\\\%\\\jpeg/;
   set P3=s/\^#JPEG_INCLUDE/JPEG_INCLUDE/;
   set P4=s/\^#JPEG_LIB.*/JPEG_LIB = \$(JPEGDIR)\\\\libjpeg.lib/;
   set P5=s/\^#ZIP_SUPPORT.*/ZIP_SUPPORT = 1/;
   set P6=s/\^#ZLIBDIR.*/ZLIBDIR = %ROOTDIR:\=\\\%\\\zlib/;
   set P7=s/\^#ZLIB_INCLUDE/ZLIB_INCLUDE/;
   set P8=s/\^#ZLIB_LIB.*/ZLIB_LIB = \$(ZLIBDIR)\\\zlib.lib/;
       
   set PATTERN="%P1%%P2%%P3%%P4%%P5%%P6%%P7%%P8%"
   sed %PATTERN%  nmake.opt > nmake.opt.fixed
   move /Y nmake.opt.fixed nmake.opt
   nmake /f Makefile.vc
   cd %ROOTDIR%
)

if not exist %ROOTDIR%\cairo (
echo "->cairo"
bsdtar xvfz %PKGDIR%\cairo-%CAIRO_VERSION%.tar.gz
rename cairo-%CAIRO_VERSION% cairo
cd cairo 
set INCLUDE=%INCLUDE%;%ROOTDIR%\zlib
set INCLUDE=%INCLUDE%;%ROOTDIR%\libpng
set INCLUDE=%INCLUDE%;%ROOTDIR%\pixman\pixman
set INCLUDE=%INCLUDE%;%ROOTDIR%\cairo\boilerplate
set INCLUDE=%INCLUDE%;%ROOTDIR%\cairo\src
set INCLUDE=%INCLUDE%;%ROOTDIR%\freetype\include

patch -p1 < ../cairo-win32.patch
make -f Makefile.win32 "CFG=release"
cd %ROOTDIR%
)

if not exist %ROOTDIR%\proj (
   echo "->proj"
   bsdtar xvfz %PKGDIR%\proj-%PROJ_VERSION%.tar.gz 
   rename proj-%PROJ_VERSION% proj
   cd proj
   nmake /f Makefile.vc
   cd %ROOTDIR%	
)

if not exist %ROOTDIR%\gdal (
   echo "->gdal"
   bsdtar xvfz %PKGDIR%\gdal-%GDAL_VERSION%.tar.gz		
   rename gdal-%GDAL_VERSION% gdal
   cd gdal
   nmake /f Makefile.vc MSVC_VER=1500
   cd %ROOTDIR%
)  

rem bjam toolset=msvc release
rem set BOOST_DIR="d:\mapnik_build\thirdparty\boost_1_47_0"
rem echo "building BOOST"
rem cd %BOOST_DIR%
rem bjam toolset=msvc -sHAVE_ICU=1 -sICU_PATH=d:\mapnik_build\thirdparty\icu --prefix=d:\boost link=shared,static python=2.7 --without-mpi --without-graph install
rem cd ..

echo "Done!"