@echo off

set STARTTIME=%TIME%
set ROOTDIR=c:\dev2
@rem note - MAPNIK_DEPS_DIR and MAPNIK_SOURCE
@rem are needed by bjam files
@rem so do not rename or remove them
set MAPNIK_DEPS_DIR=%ROOTDIR%
set MAPNIK_SOURCE=%ROOTDIR%\mapnik

set BOOST_VERSION=49
set BOOST_PREFIX=boost-%BOOST_VERSION%-vc100
set BOOST_INCLUDES=%ROOTDIR%\%BOOST_PREFIX%\include\boost-1_%BOOST_VERSION%
set BOOST_LIBS=%ROOTDIR%\%BOOST_PREFIX%\lib
set PREFIX=c:\mapnik-v2.2.0
set PATH=%ROOTDIR%\boost_1_%BOOST_VERSION%_0;%PATH%

@rem copy sparsehash - TODO add this copy to the Jamroot
xcopy /i /s %MAPNIK_SOURCE%\deps\mapnik\sparsehash %PREFIX%\include\mapnik\sparsehash /Y
xcopy /i /s %MAPNIK_SOURCE%\deps\agg\include %PREFIX%\include\mapnik\agg /Y
xcopy /i /s %MAPNIK_SOURCE%\deps\clipper\include %PREFIX%\include\mapnik\agg /Y

@rem copy all libs of dependencies
@rem expat, needed by ogr plugin
copy "C:\Program Files (x86)\Expat 2.1.0\Bin\libexpat.dll" %PREFIX%\lib\
@rem the rest, needed by libmapnik
copy %ROOTDIR%\cairo\src\release\cairo.dll %PREFIX%\lib\
copy %ROOTDIR%\icu\bin\icuuc48.dll %PREFIX%\lib\
copy %ROOTDIR%\icu\bin\icudt48.dll %PREFIX%\lib\
copy %ROOTDIR%\icu\bin\icuin48.dll %PREFIX%\lib\
copy %ROOTDIR%\libxml2\win32\bin.msvc\libxml2.dll %PREFIX%\lib\
copy %ROOTDIR%\proj\src\proj.dll %PREFIX%\lib\
copy %ROOTDIR%\boost-49-vc100\lib\boost_python-vc100-mt-1_49.dll %PREFIX%\python\2.7\site-packages\mapnik

@rem python file
copy %MAPNIK_SOURCE%\bindings\python\mapnik\__init__.py  %PREFIX%\python\2.7\site-packages\mapnik
copy %MAPNIK_SOURCE%\bindings\python\mapnik\printing.py  %PREFIX%\python\2.7\site-packages\mapnik

@rem copy .lib and headers for development
@rem xcopy /i /s %ROOTDIR%\boost-49-vc100\include\boost-1_49\boost %PREFIX%\include /Y
@rem xcopy /i /s %ROOTDIR%\icu\include\unicode %PREFIX%\include /Y
@rem copy %ROOTDIR%\cairo\cairo-version.h %PREFIX%\include
@rem copy %ROOTDIR%\cairo\cairo-deprecated.h %PREFIX%\include
@rem copy %ROOTDIR%\cairo\cairo-features.h %PREFIX%\include
@rem copy %ROOTDIR%\cairo\cairo-features.h %PREFIX%\include
@rem xcopy /i /s %ROOTDIR%\freetype\include\freetype %PREFIX%\include /Y
@rem copy %ROOTDIR%\freetype\include\ft2build.h %PREFIX%\include
copy build\src\msvc-10.0\release\threading-multi\mapnik.lib %PREFIX%\lib
copy %ROOTDIR%\icu\lib\icuuc.lib %PREFIX%\lib
copy %ROOTDIR%\icu\lib\icuin.lib %PREFIX%\lib
copy %ROOTDIR%\cairo\src\release\cairo.lib %PREFIX%\lib
copy %ROOTDIR%\boost-49-vc100\lib\libboost_system-vc100-mt-s-1_49.lib %PREFIX%\lib
copy %ROOTDIR%\boost-49-vc100\lib\libboost_thread-vc100-mt-1_49.lib %PREFIX%\lib
copy %ROOTDIR%\boost-49-vc100\lib\libboost_date_time-vc100-mt-1_49.lib %PREFIX%\lib
copy %ROOTDIR%\boost-49-vc100\lib\libboost_regex-vc100-mt-1_49.lib %PREFIX%\lib



bjam toolset=msvc -j2 --python=true --prefix=%PREFIX% -sBOOST_INCLUDES=%BOOST_INCLUDES% -sBOOST_LIBS=%BOOST_LIBS% -sMAPNIK_DEPS_DIR=%MAPNIK_DEPS_DIR% -sMAPNIK_SOURCE=%MAPNIK_SOURCE%

@rem python - paths.py, printing.py, __init__.py, boost python dll
echo Started at %STARTTIME%, finished at %TIME%

