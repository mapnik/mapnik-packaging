@echo off

set BOOST_INCLUDES=d:\boost\include\boost-1_47
set BOOST_LIBS=d:\boost\lib
set MAPNIK_DEPS_DIR=d:\mapnik_build\mapnik_deps_vc9
set MAPNIK_SOURCE=d:\mapnik_build\mapnik
set PREFIX=c:\mapnik-2.0

bjam toolset=msvc-9.0 --prefix=%PREFIX% -sBOOST_INCLUDES=%BOOST_INCLUDES% -sBOOST_LIBS=%BOOST_LIBS% -sMAPNIK_DEPS_DIR=%MAPNIK_DEPS_DIR% -sMAPNIK_SOURCE=%MAPNIK_SOURCE%
