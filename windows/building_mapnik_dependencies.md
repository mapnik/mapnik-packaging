# Building Mapnik dependencies on Windows 

*(Visual C++ express 2008 and 2010 32-bit)*

Buiding dependencies on windows can be very tedious. The goal here is to provide
concise instructions for building individual packages using either VC++ 2008 and 2010.

Hopefully, this will allow fully automated builds in the future.

## Prerequisites

* Visual C++ 2008 or 2010 Express
  * http://www.microsoft.com/visualstudio/en-us/products/2008-editions/visual-basic-express
  * http://www.microsoft.com/visualstudio/en-us/products/2010-editions/visual-basic-express
* GNU Unix tools (GnuWin32) 
      * [bsdtar](http://gnuwin32.sourceforge.net/packages/libarchive.htm) 
      * [make](http://gnuwin32.sourceforge.net/packages/make.htm)
      * [wget](http://downloads.sourceforge.net/gnuwin32/wget-1.11.4-1-setup.exe)
* [msysgit](http://msysgit.googlecode.com/files/Git-1.7.7.1-preview20111027.exe) - install into c:/Git to avoid issues with spaces in paths
* unzip (from [msysgit](http://code.google.com/p/msysgit/))
* patch (from [msysgit](http://code.google.com/p/msysgit/))
* sed (from [msysgit](http://code.google.com/p/msysgit/))
* curl (from [msysgit](http://code.google.com/p/msysgit/))
* [cygwin](http://www.cygwin.org) (install bash,make,coreutils) - needed to build pixman and icu (vs 2008)

## Environment

We'll be using combination of "Visual Studio 2008 Command Prompt" (or "Visual Studio 2010 Command Prompt") and GNU
tools. Please, ensure PATH is setup correctly and GNU tools can be accessed from VC++ command prompt.
The order in %PATH% variable is important (Git / Cygwin / GnuWin32 )

    set PATH=%PATH%;c:\msysgit\msysgit\bin;c:\cygwin\bin;c:\GnuWin32\bin
    set ROOTDIR=c:\dev2
    cd %ROOTDIR%
    mkdir packages 
    set PKGDIR=%ROOTDIR%/packages

### Packages versions:

    set ICU_VERSION=4.8
    set BOOST_VERSION=49
    set ZLIB_VERSION=1.2.5
    set LIBPNG_VERSION=1.5.10
    set JPEG_VERSION=8d
    set FREETYPE_VERSION=2.4.9
    set POSTGRESQL_VERSION=9.1.3
    set TIFF_VERSION=4.0.0beta7
    set PROJ_VERSION=4.8.0
    set PROJ_GRIDS_VERSION=1.5
    set GDAL_VERSION=1.9.0
    set LIBXML2_VERSION=2.7.8
    set PIXMAN_VERSION=0.22.2
    set CAIRO_VERSION=1.10.2
    set SQLITE_VERSION=3071100
    set EXPAT_VERSION=2.1.0
    set GEOS_VERSION=3.3.3
    
## Download

    wget https://raw.github.com/mapnik/mapnik-packaging/master/windows/cairo-win32.patch --no-check-certificate
    wget https://raw.github.com/mapnik/mapnik-packaging/master/windows/libxml.patch --no-check-certificate

    cd %PKGDIR%
    curl http://iweb.dl.sourceforge.net/project/boost/boost/1.%BOOST_VERSION%.0/boost_1_%BOOST_VERSION%_0.tar.gz -O
    curl http://www.ijg.org/files/jpegsr%JPEG_VERSION%.zip -O
    curl http://ftp.igh.cnrs.fr/pub/nongnu/freetype/freetype-%FREETYPE_VERSION%.tar.gz -O
    curl http://ftp.de.postgresql.org/packages/databases/PostgreSQL/latest/postgresql-%POSTGRESQL_VERSION%.tar.gz -O
    curl ftp://ftp.simplesystems.org/pub/libpng/png/src/libpng-%LIBPNG_VERSION%.tar.gz -O
    curl http://www.zlib.net/zlib-%ZLIB_VERSION%.tar.gz -O
    curl http://download.osgeo.org/libtiff/tiff-%TIFF_VERSION%.tar.gz -O
    curl http://www.cairographics.org/releases/pixman-%PIXMAN_VERSION%.tar.gz -O
    curl http://www.cairographics.org/releases/cairo-%CAIRO_VERSION%.tar.gz -O
    curl http://download.icu-project.org/files/icu4c/4.8.1.1/icu4c-4_8_1_1-src.tgz -O
    curl ftp://xmlsoft.org/libxml2/libxml2-%LIBXML2_VERSION%.tar.gz -O
    curl http://iweb.dl.sourceforge.net/project/expat/expat_win32/%EXPAT_VERSION%/expat-win32bin-%EXPAT_VERSION%.exe -O
    curl http://download.osgeo.org/gdal/gdal-%GDAL_VERSION%.tar.gz -O
    curl http://www.sqlite.org/sqlite-amalgamation-%SQLITE_VERSION%.zip -O
    curl http://download.osgeo.org/proj/proj-%PROJ_VERSION%.tar.gz -O
    curl http://download.osgeo.org/proj/proj-datumgrid-%PROJ_GRIDS_VERSION%.zip -O
    curl http://download.osgeo.org/geos/geos-%GEOS_VERSION%.tar.bz2 -O

    cd %ROOTDIR%
    
## Building individual packages

*NOTE: Some packages require different commands depending on the VC++ version.
To avoid run-time clashes, it is a good idea to have a separate %ROOTDIR% 
for every build variant.*

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

### boost

    bsdtar xzf %PKGDIR%/boost_1_%BOOST_VERSION%_0.tar.gz
    cd boost_1_%BOOST_VERSION%_0
    set BOOST_PREFIX=boost-%BOOST_VERSION%-vc100
    bootstrap.bat
    bjam toolset=msvc --prefix=..\\%BOOST_PREFIX% --with-thread --with-filesystem --with-date_time --with-system --with-program_options --with-regex --with-chrono --disable-filesystem2 -sHAVE_ICU=1 -sICU_PATH=%ROOTDIR%\\icu -sICU_LINK=%ROOTDIR%\\icu\\lib\\icuuc.lib release link=static install --build-type=complete

    # if you need python
    bjam toolset=msvc --prefix=..\\%BOOST_PREFIX% --with-python python=2.7 release link=static --build-type=complete install

### Jpeg

    unzip %PKGDIR%\jpegsr%JPEG_VERSION%.zip
    rename jpeg-%JPEG_VERSION% jpeg
    cd jpeg 
    copy jconfig.txt jconfig.h
    nmake /f Makefile.vc nodebug=1
    cd %ROOTDIR%

### Freetype 

    bsdtar xfz "%PKGDIR%\freetype-%FREETYPE_VERSION%.tar.gz"
    rename freetype-%FREETYPE_VERSION% freetype
    cd freetype

##### VC++ 2008

    vcbuild builds\win32\vc2008\freetype.vcproj "Release|Win32"

##### VC++ 2010

    msbuild builds\win32\vc2010\freetype.sln /p:Configuration=Release /p:Platform=Win32

    move objs\win32\vc2010\freetype249.lib freetype.lib
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
    set INCLUDE=%INCLUDE%;%ROOTDIR%\cairo
    set INCLUDE=%INCLUDE%;%ROOTDIR%\cairo\src
    set INCLUDE=%INCLUDE%;%ROOTDIR%\freetype\include
    patch -p1 < ..\cairo-win32.patch
    make -f Makefile.win32 "CFG=release"
    @rem - delete bogus cairo-version.h
    @rem https://github.com/mapnik/mapnik-packaging/issues/56
    del src\cairo-version.h
    del
    cd %ROOTDIR%

### LibXML2

    bsdtar xvfz %PKGDIR%\libxml2-%LIBXML2_VERSION%.tar.gz
    rename libxml2-%LIBXML2_VERSION% libxml2
    cd libxml2\win32
    cscript configure.js compiler=msvc prefix=%ROOTDIR%\libxml2 iconv=no icu=yes include=%ROOTDIR%\icu\include lib=%ROOTDIR%\icu\lib
    patch  -p1 < ..\libxml.patch
    nmake /f Makefile.msvc
    cd %ROOTDIR%

### Proj4

#### Official release

    bsdtar xfz %PKGDIR%\proj-%PROJ_VERSION%.tar.gz
    rename proj-%PROJ_VERSION% proj
    cd proj/nad
    unzip -o ../../proj-datumgrid-%PROJ_GRIDS_VERSION%.zip
    cd ..\
    nmake /f Makefile.vc
    cd %ROOTDIR%

### Expat (for GDAL's KML,GPX, GeoRSS read support)

    @rem - run the binary installer
    start expat-win32bin-%EXPAT_VERSION%.exe

### GDAL

    bsdtar xvfz %PKGDIR%\gdal-%GDAL_VERSION%.tar.gz
    rename gdal-%GDAL_VERSION% gdal
    cd gdal

    @rem Edit the 'name.opt' to point to the location the expat binary was installed to:
    @rem EXPAT_DIR="C:\Program Files (x86)\Expat 2.1.0"

##### VC++ 2008

    nmake /f makefile.vc MSVC_VER=1500

##### VC++ 2010

    nmake /f makefile.vc MSVC_VER=1600
 
    cd %ROOTDIR%


### sqlite 

*NOTE: there's no build step for sqlite, we simply unzip archive and rename dir*

    unzip %PKGDIR%\sqlite-amalgamation-%SQLITE_VERSION%.zip
    rename sqlite-amalgamation-%SQLITE_VERSION% sqlite

If you want to build sqlite standalone you might be interested in: https://skydrive.live.com/view.aspx?resid=A737583042956228!1940&cid=a737583042956228

### protobuf
*NOTE: only needed if building node-mapnik with vector tiles support

Download https://protobuf.googlecode.com/files/protobuf-2.5.0.zip and unzip

    rename protobuf-2.5.0 protobuf
    cd protobuf\vcprojects
    vcupgrade libprotobuf-lite.vcproj
    vcupgrade libprotobuf.vcproj
    vcupgrade protoc.vcproj
    msbuild libprotobuf-lite.vcxproj /p:Configuration="Release" /p:Platform=Win32
    msbuild libprotobuf.vcxproj /p:Configuration="Release" /p:Platform=Win32
    # fails linking so I used binary from google code
    #msbuild protoc.vcxproj /p:Configuration="Release" /p:Platform=Win32
    extract_includes.bat
    
    
    
### GEOS

*NOTE: this is optional as GEOS is not used by Mapnik*

    bsdtar xvf geos-%GEOS_VERSION%.tar.bz2
    rename geos-%GEOS_VERSION% geos

##### VC++ 2010

    cd geos
    mkdir build
    cd build
    cmake -G ..\
    nmake /f Makefile geos
