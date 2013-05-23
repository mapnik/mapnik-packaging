@echo off

set ROOTDIR=c:\dev2

@rem critical global variables needed by bjam
set MAPNIK_DEPS_DIR=%ROOTDIR%
set MAPNIK_SOURCE=%ROOTDIR%\mapnik
set PYTHON_VERSION="27"
set PYTHON_ROOT=C:\\Python%PYTHON_VERSION%;

@rem other variables
set BOOST_VERSION=49
set BOOST_PREFIX=boost-%BOOST_VERSION%-vc100
set BOOST_INCLUDES=%ROOTDIR%\%BOOST_PREFIX%\include\boost-1_%BOOST_VERSION%
set BOOST_LIBS=%ROOTDIR%\%BOOST_PREFIX%\lib
set PREFIX=c:\mapnik-v2.2.0
set PATH=%ROOTDIR%\boost_1_%BOOST_VERSION%_0;%PATH%
set STARTTIME=%TIME%

bjam toolset=msvc -j2 --python=true --prefix=%PREFIX% -sBOOST_INCLUDES=%BOOST_INCLUDES% -sBOOST_LIBS=%BOOST_LIBS% -sMAPNIK_DEPS_DIR=%MAPNIK_DEPS_DIR% -sMAPNIK_SOURCE=%MAPNIK_SOURCE%

echo Started at %STARTTIME%, finished at %TIME%

