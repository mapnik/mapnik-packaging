# Welcome to Mapnik

## Installing

Run the Mapnik.pkg.

Then open a new terminal.

You should be able to:

1) Use mapnik from python: 
     
    python -c "import mapnik;print mapnik.mapnik_version_string()"

2) Use the `mapnik-config` tool to get info about the install:
 
    mapnik-config --version

3) And the command `which mapnik-config` should return:

    $ which mapnik-config
    /Library/Frameworks/Mapnik.framework/unix/bin/mapnik-config


## Installation Details

This installer only works for Intel 64 bit enabled OS X 10.6, 10.7, and 10.8.

This installer places Mapnik at:

    /Library/Frameworks/Mapnik.framework

It enables Mapnik's bindings for Python 2.6 and 2.7 by placing these two files:

    /Library/Python/2.6/site-packages/mapnik.pth
    /Library/Python/2.7/site-packages/mapnik.pth

And it automatically puts the 'mapnik-config' program on your ${PATH} by placing this file:

    /etc/paths.d/mapnik


## Core Functionality

This Mapnik installer includes:

 * Mapnik Core (libmapnik.dylib)
 
 * Python bindings compatible with versions:
    - 2.6 and 2.7
 
 * Datasources (aka "input plugins"):
    - Shapefile, PostGIS, Raster, GDAL, OGR, SQLite, and CSV
 
 * Other libs: Boost, ICU, Cairo, Freetype2, and Proj4


## What next?

Join the Mapnik community list by signing up at http://mapnik.org/contact/

Jump on IRC to ask questions: irc://irc.freenode.net#mapnik

If you need help designing stylesheets for Mapnik see:

    http://mapbox.com/tilemill

If you want to serve tiles see:

    http://tilestache.org

For general Mapnik resources see the wiki:

    https://github.com/mapnik/mapnik/wiki


## Issues?

Any questions or problems with the *installer* please post an issue at:

    https://github.com/mapnik/mapnik-packaging/issues

Problems with Mapnik itself please post an issue at:

    https://github.com/mapnik/mapnik/issues