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
xcopy /i /d /s /q %ROOTDIR%\boost-49-vc100\include\boost-1_49\boost %PREFIX%\include\boost /Y
xcopy /i /d /s %ROOTDIR%\icu\include\unicode %PREFIX%\include\unicode /Y
xcopy /i /d /s %ROOTDIR%\freetype\include\freetype %PREFIX%\include\freetype /Y

xcopy /i /d /s %ROOTDIR%\proj\nad %PREFIX%\share\proj
xcopy /i /d /s %ROOTDIR%\gdal\data %PREFIX%\share\gdal

echo from os import path > mapnik_settings.py
echo mapnik_data_dir = path.normpath(path.join(__file__,'../../../../../share/')) >> mapnik_settings.py
echo env = { >> mapnik_settings.py
echo     'GDAL_DATA': path.join(mapnik_data_dir, 'gdal'), >> mapnik_settings.py
echo     'PROJ_LIB': path.join(mapnik_data_dir, 'proj') >> mapnik_settings.py
echo } >> mapnik_settings.py
echo __all__ = [env] >> mapnik_settings.py

echo from os import path > paths.py
echo mapniklibpath = path.normpath(path.join(__file__,'../../../../../lib/')) >> paths.py
echo inputpluginspath = path.join(mapniklibpath,'mapnik/input') >> paths.py
echo fontscollectionpath = path.join(mapniklibpath,'mapnik/fonts') >> paths.py
echo __all__ = [mapniklibpath,inputpluginspath,fontscollectionpath] >> paths.py



bjam toolset=msvc -j2 --python=true --prefix=%PREFIX% -sBOOST_INCLUDES=%BOOST_INCLUDES% -sBOOST_LIBS=%BOOST_LIBS% -sMAPNIK_DEPS_DIR=%MAPNIK_DEPS_DIR% -sMAPNIK_SOURCE=%MAPNIK_SOURCE%

copy build/src/msvc-10.0/release/threading-multi/mapnik.lib %PREFIX%/lib

echo Started at %STARTTIME%, finished at %TIME%

