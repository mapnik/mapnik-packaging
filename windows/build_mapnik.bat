@echo off

set BOOST_INCLUDES=c:\dev2\boost-vc100\include\boost-1_48
set BOOST_LIBS=c:\dev2\boost-vc100\lib
set MAPNIK_DEPS_DIR=c:\dev2\
set MAPNIK_SOURCE=c:\dev2\mapnik
set PREFIX=c:\mapnik-2.0
set PATH=c:\dev2\boost_1_48_0;%PATH%

bjam toolset=msvc -j2 --prefix=%PREFIX% -sBOOST_INCLUDES=%BOOST_INCLUDES% -sBOOST_LIBS=%BOOST_LIBS% -sMAPNIK_DEPS_DIR=%MAPNIK_DEPS_DIR% -sMAPNIK_SOURCE=%MAPNIK_SOURCE%
