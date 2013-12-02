# Build and Package Mapnik for windows

These are working notes on building Mapnik from source on windows.

 - Currently these instructions target the upcoming Mapnik 2.3.x release.
 - This is being tested on windows 7 64 bit.
 - This is currently only tested with release builds in 32 bit. 64 bit support is planned, but not tested yet.

## Visual Studio versions.

These notes attempt to map out the steps to compile Mapnik and dependencies with either VS 2008 or VS 2010. We also plan to support VS 2012.

## Setup

### Step 1: Build Mapnik dependencies

See the [building_mapnik_dependencies.md](https://github.com/mapnik/mapnik-packaging/blob/master/windows/building_mapnik_dependencies.md) document for details on building Mapnik dependencies.

Step through it copying and pasting chunks of commands, ensuring they work before
continuing.

### Step 2: Download and build Mapnik

Currently we are targeting Mapnik 2.3.x:

    git clone https://github.com/mapnik/mapnik.git -b 2.3.x mapnik

Next edit the `build_mapnik.bat` and ensure the variables match your system (https://github.com/mapnik/mapnik-packaging/blob/18bb66ba95540c069acaf267ea7594bfd83734d9/windows/build_mapnik.bat#L3-L12). In particular ensure that the `MAPNIK_SOURCE` variable points the git checkout you just made above.

Then run the `build_mapnik.bat`:

    cd mapnik-packaging/windows
    build_mapnik.bat 1> build.log

Mapnik should be compiled and placed in the folder pointed to by the `PREFIX` variable in `build_mapnik.bat`

If you hit errors you can ask for help by creating an issue at https://github.com/mapnik/mapnik-packaging/issues?state=open

## Gochas
  
The VS 2008 `vcbuild` command is [broken on arrival](http://blogs.msdn.com/b/windowssdk/archive/2007/09/06/sdk-workaround.aspx)

It complains about write-access. To fix it do:

    cd C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\vcpackages
    regsvr32 vcprojectengine.dll
