# Build and Package Mapnik for windows

This assumes a vanilla install of windows.

This is being tested on windows 7 64 bit.

## Gochas

http://blogs.msdn.com/b/windowssdk/archive/2007/09/06/sdk-workaround.aspx

    cd C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\vcpackages
    regsvr32 vcprojectengine.dll


## TODO

Need proj4 nad files
Patch from gnuwin32 segfaults


## Setup

Add gnuwin32 bin directory to your path:

    C:\Program Files (x86)\GnuWin32\bin

Download Windows SDK:

    http://www.microsoft.com/download/en/details.aspx?displaylang=en&id=8279

Download Visual C++ express 2008

    http://www.microsoft.com/visualstudio/en-us/products/2008-editions/express
    
Not 2010! because it breaks boost and does not work with python.org downloads (which are build against 2008):

    http://www.microsoft.com/visualstudio/en-us/products/2010-editions/visual-cpp-express

Download various gnuwin32 tools:

wget

    http://downloads.sourceforge.net/gnuwin32/wget-1.11.4-1-setup.exe

make

    http://gnuwin32.sourceforge.net/downlinks/make.php

bsdtar

    http://downloads.sourceforge.net/gnuwin32/libarchive-2.4.12-1-setup.exe

unzip

    http://gnuwin32.sourceforge.net/downlinks/unzip.php

sed

    http://sourceforge.net/projects/gnuwin32/files//sed/4.2.1/sed-4.2.1-setup.exe/download

patch

    http://gnuwin32.sourceforge.net/downlinks/patch.php

curl - 32 bit against VS 2008

    http://curl.freeby.pctools.cl/download/curl-7.19.5-win32-nossl.zip


Create a directory:

    C:\dev
   
Copy scripts there.

Then open VS 2008 and go to:

    Menu > Tools > Visual Studio 2008 Command Prompt

Type:

    cd c:\dev
    
Make sure these commands work (return usage):

    vcbuild
    make
    curl
    sed
    unzip
    bsdtar
    wget
    patch

Now run the dependencies build script:

    build_mapnik_deps.bat
