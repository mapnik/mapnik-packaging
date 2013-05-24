@echo off

set ROOTDIR=c:\\dev2
set PREFIX=c:\\mapnik-v2.2.0

@rem critical global variables needed by bjam
set MAPNIK_DEPS_DIR=%ROOTDIR%
set MAPNIK_SOURCE=%ROOTDIR%\mapnik
set PYTHON_VERSION=2.7
set PYTHON_VERSION2=27
set PYTHON_ROOT=C:\Python%PYTHON_VERSION2%

@rem other variables
set BOOST_VERSION=49
set BOOST_PREFIX=boost-%BOOST_VERSION%-vc100
set BOOST_INCLUDES=%ROOTDIR%\%BOOST_PREFIX%\include\boost-1_%BOOST_VERSION%
set BOOST_LIBS=%ROOTDIR%\%BOOST_PREFIX%\lib
set PATH=%ROOTDIR%\boost_1_%BOOST_VERSION%_0;%PATH%
set STARTTIME=%TIME%

@rem - note: these are here instead of in the Jamroot because
@rem I was unable to figure out the correct glob syntax for copying
@rem directories - bjam would say "Unable to find target or file"
xcopy /i /d /s %MAPNIK_SOURCE%\deps\mapnik\sparsehash %PREFIX%\include\mapnik\sparsehash /Y
xcopy /i /d /s %MAPNIK_SOURCE%\deps\agg\include %PREFIX%\include\mapnik\agg /Y
xcopy /i /d /s %MAPNIK_SOURCE%\deps\clipper\include %PREFIX%\include\mapnik\agg /Y
xcopy /i /d /s /q %ROOTDIR%\boost-49-vc100\include\boost-1_49\boost %PREFIX%\include /Y
xcopy /i /d /s %ROOTDIR%\icu\include\unicode %PREFIX%\include /Y
xcopy /i /d /s %ROOTDIR%\freetype\include\freetype %PREFIX%\include /Y


bjam toolset=msvc -j2 --python=true --prefix=%PREFIX% -sBOOST_INCLUDES=%BOOST_INCLUDES% -sBOOST_LIBS=%BOOST_LIBS% -sMAPNIK_DEPS_DIR=%MAPNIK_DEPS_DIR% -sMAPNIK_SOURCE=%MAPNIK_SOURCE%

echo Started at %STARTTIME%, finished at %TIME%

