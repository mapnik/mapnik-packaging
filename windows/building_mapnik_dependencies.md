# Building Mapnik dependencies on Windows 

*(Visual C++ express 2008 and 2010 32-bit)*

Buiding dependencies on windows can be very tedious. The goal here is to provide
concise instructions for building individual packages using both VC++ 2008 and 2010.
Hopefully, this will allow fully automated builds in the future.

## Prerequisites

* Visual C++ 2008 or 2010 Express
* GNU Unix tools (GnuWin32) 
      * [bsdtar](http://gnuwin32.sourceforge.net/packages/libarchive.htm) 
      * [make](http://gnuwin32.sourceforge.net/packages/make.htm)
* [msysgit](http://msysgit.googlecode.com/files/Git-1.7.7.1-preview20111027.exe) - install into c:/Git to avoid issues with spaces in paths
* unzip (from [msysgit](http://code.google.com/p/msysgit/))
* patch (from [msysgit](http://code.google.com/p/msysgit/))
* sed (from [msysgit](http://code.google.com/p/msysgit/))
* curl (from [msysgit](http://code.google.com/p/msysgit/))
* [cygwin](http://www.cygwin.org) (bash,make,ar ...) - to build ICU using vc++ 2008 FIXME!

## Environment

We'll be using combination of "Visual Studio 2008 Command Prompt" (or "Visual Studio 2010 Command Prompt") and GNU
tools. Please, ensure PATH is setup correctly and GNU tools can be accessed from VC++ command prompt.
The order in %PATH% variable is important (Git / Cygwin / GnuWin32 )

    set PATH=%PATH%;c:\msysgit\msysgit\bin;c:\cygwin\bin;c:\GnuWin32\bin
    set ROOTDIR=<mapnik_dependencies_dir>
    cd %ROOTDIR%
    mkdir packages 
    set PKGDIR=%ROOTDIR%/packages

### Packages versions:

    set ZLIB_VERSION=1.2.5
    set LIBPNG_VERSION=1.5.6
    set PIXMAN_VERSION=0.22.2
    set CAIRO_VERSION=1.10.2
    set JPEG_VERSION=8c
    set FREETYPE_VERSION=2.4.7
    set POSTGRESQL_VERSION=9.1.1
    set TIFF_VERSION=4.0.0beta7
    set PROJ_VERSION=4.7.0
    set GDAL_VERSION=1.8.1
    set ICU_VERSION=4.8
    set LIBXML2_VERSION=2.7.8
    set LIBSIGC++_VERSION=2.2.10
    set CAIROMM_VERSION=1.10.0
    set SQLITE_VERSION=3070900
    
## Download

    wget https://raw.github.com/mapnik/mapnik-packaging/master/windows/cairo-win32.patch --no-check-certificate
    wget https://raw.github.com/mapnik/mapnik-packaging/master/windows/cairomm-1.10.0-vc10-20111121.patch --no-check-certificate   
    wget https://raw.github.com/mapnik/mapnik-packaging/master/windows/libxml-20111118.patch --no-check-certificate
    	 
    cd %PKGDIR%
    curl http://www.ijg.org/files/jpegsr%JPEG_VERSION%.zip -O
    curl http://ftp.igh.cnrs.fr/pub/nongnu/freetype/freetype-%FREETYPE_VERSION%.tar.gz -O
    curl http://ftp.de.postgresql.org/packages/databases/PostgreSQL/latest/postgresql-%POSTGRESQL_VERSION%.tar.gz -O
    curl ftp://ftp.simplesystems.org/pub/libpng/png/src/libpng-%LIBPNG_VERSION%.tar.gz -O
    curl http://www.zlib.net/zlib-%ZLIB_VERSION%.tar.gz -O
    curl http://download.osgeo.org/libtiff/tiff-%TIFF_VERSION%.tar.gz -O
    curl http://www.cairographics.org/releases/pixman-%PIXMAN_VERSION%.tar.gz -O
    curl http://caesar.acc.umu.se/pub/GNOME/sources/libsigc++/2.2/libsigc++-%LIBSIGC++_VERSION%.tar.bz2 -O
    curl http://www.cairographics.org/releases/cairo-%CAIRO_VERSION%.tar.gz -O
    curl http://www.cairographics.org/releases/cairomm-%CAIROMM_VERSION%.tar.gz -O
    curl http://download.icu-project.org/files/icu4c/4.8.1.1/icu4c-4_8_1_1-src.tgz -O
    curl ftp://xmlsoft.org/libxml2/libxml2-%LIBXML2_VERSION%.tar.gz -O
    curl http://download.osgeo.org/gdal/gdal-%GDAL_VERSION%.tar.gz -O
    curl http://www.sqlite.org/sqlite-amalgamation-%SQLITE_VERSION%.zip -O
    curl http://download.osgeo.org/proj/proj-%PROJ_VERSION%.tar.gz -O
    
    cd %ROOTDIR%
    
## Building individual packages

*NOTE: Some packages require different commands depending on the VC++ version.
To avoid run-time clashes, it is a good idea to have a separate %ROOTDIR% 
for every build variant.*

### Jpeg

    unzip %PKGDIR%\jpegsr%JPEG_VERSION%.zip
    rename jpeg-%JPEG_VERSION% jpeg
    cd jpeg 
    copy jconfig.txt jconfig.h
    nmake /f Makefile.vc nodebug=1
    cd %ROOTDIR%

### Freetype 

    bsdtar xvfz "%PKGDIR%\freetype-%FREETYPE_VERSION%.tar.gz"
    rename freetype-%FREETYPE_VERSION% freetype
    cd freetype

##### VC++ 2008

    vcbuild builds\win32\vc2008\freetype.vcproj "Release|Win32"

##### VC++ 2010

    msbuild builds\win32\vc2010\freetype.sln /p:Configuration=Release /p:Platform=Win32

    move objs\win32\vc2010\freetype247.lib freetype.lib
    cd %ROOTDIR%


### zlib

zlib comes with old VC++ project files. Instead we use upgraded project file from libpng:

    bsdtar xvfz %PKGDIR%\libpng-%LIBPNG_VERSION%.tar.gz
    rename libpng-%LIBPNG_VERSION% libpng

    bsdtar xvfz %PKGDIR%\zlib-%ZLIB_VERSION%.tar.gz
    rename zlib-%ZLIB_VERSION% zlib
    mkdir %ROOTDIR%\zlib\projects\visualc71
    cd %ROOTDIR%\zlib\projects\visualc71
    copy %ROOTDIR%\libpng\projects\visualc71\zlib.vcproj .

##### VC++ 2008

    msbuild /upgrade zlib.vcproj
    vcbuild zlib.vcproj "LIB Release"

##### VC++ 2010

    vcupgrade zlib.vcproj
    msbuild zlib.vcxproj /t:Rebuild /p:Configuration="LIB Release" /p:Platform=Win32

    cd %ROOTDIR%\zlib
    move projects\visualc71\Win32_LIB_Release\ZLib\zlib.lib zlib.lib
    cd  %ROOTDIR%

### libpng

    cd %ROOTDIR%\libpng\projects\visualc71

##### VC++ 2008

    vcbuild /upgrade libpng.vcproj
    vcbuild libpng.vcproj "LIB Release"

##### VC++ 2010

    vcupgrade libpng.vcproj
    msbuild libpng.vcxproj /t:Rebuild  /p:Configuration="LIB Release" /p:Platform=Win32
    
    cd %ROOTDIR%\libpng
    move projects\visualc71\Win32_LIB_Release\libpng.lib libpng.lib
    cd %ROOTDIR%

   
### libpq (PostgreSQL C-interface)

    bsdtar xvfz "%PKGDIR%\postgresql-%POSTGRESQL_VERSION%.tar.gz"
    rename postgresql-%POSTGRESQL_VERSION% postgresql
    cd postgresql\src
    nmake /f win32.mak
    cd %ROOTDIR%


### Tiff

    bsdtar xvfz %PKGDIR%\tiff-%TIFF_VERSION%.tar.gz
    rename tiff-%TIFF_VERSION% tiff
    cd tiff
    set P1=s/\^#JPEG_SUPPORT.*/JPEG_SUPPORT = 1/;
    set P2=s/\^#JPEGDIR.*/JPEGDIR = %ROOTDIR:\=\\\%\\\jpeg/;
    set P3=s/\^#JPEG_INCLUDE/JPEG_INCLUDE/;
    set P4=s/\^#JPEG_LIB.*/JPEG_LIB = \$(JPEGDIR^)\\\libjpeg.lib/;
    set P5=s/\^#ZIP_SUPPORT.*/ZIP_SUPPORT = 1/;
    set P6=s/\^#ZLIBDIR.*/ZLIBDIR = %ROOTDIR:\=\\\%\\\zlib/;
    set P7=s/\^#ZLIB_INCLUDE/ZLIB_INCLUDE/;
    set P8=s/\^#ZLIB_LIB.*/ZLIB_LIB = \$(ZLIBDIR^)\\\zlib.lib/;                    
    set PATTERN="%P1%%P2%%P3%%P4%%P5%%P6%%P7%%P8%"
    sed %PATTERN%  nmake.opt > nmake.opt.fixed
    move /Y nmake.opt.fixed nmake.opt
    nmake /f Makefile.vc
    cd %ROOTDIR%

### Pixman
    
    bsdtar xvfz %PKGDIR%\pixman-%PIXMAN_VERSION%.tar.gz
    rename pixman-%PIXMAN_VERSION% pixman
    cd pixman\pixman
    make -f Makefile.win32 "CFG=release"
    cd %ROOTDIR%
    
### Cairo

    bsdtar xvfz %PKGDIR%\cairo-%CAIRO_VERSION%.tar.gz
    rename cairo-%CAIRO_VERSION% cairo
    cd cairo 
    set INCLUDE=%INCLUDE%;%ROOTDIR%\zlib
    set INCLUDE=%INCLUDE%;%ROOTDIR%\libpng
    set INCLUDE=%INCLUDE%;%ROOTDIR%\pixman\pixman
    set INCLUDE=%INCLUDE%;%ROOTDIR%\cairo\boilerplate
    set INCLUDE=%INCLUDE%;%ROOTDIR%\cairo\src
    set INCLUDE=%INCLUDE%;%ROOTDIR%\freetype\include
    patch -p1 < ..\cairo-win32.patch
    make -f Makefile.win32 "CFG=release"
    cd %ROOTDIR%

### ICU

    bsdtar xvfz %PKGDIR%\icu4c-4_8_1_1-src.tgz

##### VC++ 2008

    cd icu/source
    bash ./runConfigure Cygwin/MSVC --prefix=%ROOTDIR%\icu
    make install

##### VC++ 2010

    cd icu/
    msbuild source\allinone\allinone.sln /t:Rebuild  /p:Configuration="Release" /p:Platform=Win32
    
    cd %ROOTDIR%


### LibXML2

    bsdtar xvfz %PKGDIR%\libxml2-%LIBXML2_VERSION%.tar.gz       
    rename libxml2-%LIBXML2_VERSION% libxml2
    cd libxml2\win32
    cscript configure.js compiler=msvc prefix=%ROOTDIR%\libxml2 iconv=no icu=yes include=%ROOTDIR%\icu\include lib=%ROOTDIR%\icu\lib
    patch  -p1 < ..\libxml-20111118.patch
    nmake /f Makefile.msvc
    cd %ROOTDIR%

### Proj4

TODO: should we be using latest trunk, which has some threading fixes ??

    bsdtar xvfz %PKGDIR%\proj-%PROJ_VERSION%.tar.gz 
    rename proj-%PROJ_VERSION% proj
    cd proj
    nmake /f Makefile.vc
    cd %ROOTDIR%    

### GDAL

    bsdtar xvfz %PKGDIR%\gdal-%GDAL_VERSION%.tar.gz     
    rename gdal-%GDAL_VERSION% gdal
    cd gdal

##### VC++ 2008

    nmake /f makefile.vc MSVC_VER=1500

##### VC++ 2008

    nmake /f makefile.vc MSVC_VER=1600
 
    cd %ROOTDIR%


### libsigc++

    bsdtar xvfj %PKGDIR%\libsigc++-%LIBSIGC++_VERSION%.tar.bz2
    rename libsigc++-%LIBSIGC++_VERSION% libsigc++

##### VC++ 2008

    cd libsigc++\MSVC_Net2008
    vcbuild "libsigc++2.vcproj" "Release|Win32"

##### VC++ 2010

    cd libsigc++\MSVC_Net2010   
    msbuild "libsigc++2.vcxproj" /t:Rebuild /p:Configuration="Release" /p:Platform=Win32
    
    
    copy "sigc++config.h" "%ROOTDIR%\libsigc++"
    cd %ROOTDIR%

### cairomm

    bsdtar xvzf %PKGDIR%/cairomm-%CAIROMM_VERSION%.tar.gz
    rename cairomm-%CAIROMM_VERSION% cairomm

##### VC++ 2008

    set INCLUDE=%INCLUDE%;%ROOTDIR%\libsigc++;%ROOTDIR%\freetype\include;%ROOTDIR%\freetype\include\freetype;%ROOTDIR%\cairo\src
    set LIB=%LIB%;%ROOTDIR%\cairo\src\release;%ROOTDIR%\libsigc++\MSVC_Net2008\Win32\Release
    cd cairomm\MSVC_Net2008
    vcbuild cairomm.sln /useenv "Release|Win32" 

##### VC++ 2010

    cd cairomm
    patch -p1 < ..\cairomm-1.10.0-vc10-20111121.patch 
    cd MSVC_Net2010    
    msbuild /p:Configuration="Release" /p:Platform=Win32 /t:"cairomm-fixed" cairomm.sln
    cd %ROOTDIR%


### sqlite 

*NOTE: there's no build step for sqlite, we simply unzip archive and rename dir*

    unzip %PKGDIR%\sqlite-amalgamation-%SQLITE_VERSION%.zip
    rename sqlite-amalgamation-%SQLITE_VERSION% sqlite


### boost

    bootstrap.bat
    bjam toolset=msvc --prefix=..\\boost-vc100 --with-thread --with-filesystem --with-date_time --with-system --with-program_options --with-python --with-regex -sHAVE_ICU=1 -sICU_PATH=..\\icu install release link=static 
    bjam toolset=msvc --prefix=..\\boost-vc100 --with-python python=2.7 release link=shared



