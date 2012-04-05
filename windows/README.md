# Build and Package Mapnik for windows

These are working notes on building Mapnik 2.x on windows.

This is being tested on windows 7 64 bit.

## Visual Studio versions.

These notes attempt to map out the steps to compile
Mapnik and dependencies with either VS 2008 or VS 2010.

If you need python bindings, go with VS 2008 since that is what
the python.org binaries used for python 2.5-2.7.

If you need node.js bindings, the easiest path is to use VS 2010
since that is what the default node.js build scripts expect.

## Gochas
  
The VS 2008 `vcbuild` command is [broken on arrival](http://blogs.msdn.com/b/windowssdk/archive/2007/09/06/sdk-workaround.aspx)

It complains about write-access. To fix it do:

    cd C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\vcpackages
    regsvr32 vcprojectengine.dll

## Details

See the building_mapnik_dependencies.md document for building Mapnik dependencies.

Step through it copying and pasting chunks of commands, ensuring they work before
continuing.

This is ideally something that could be automated more in the future but the high
likelhood of failure states means that we've found manually running chunks is the
most sane way to get going.
