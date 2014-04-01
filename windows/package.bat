@rem no need for lib files for plugins
del c:\mapnik-%MAPNIK_VERSION%\lib\mapnik\input\*lib

del mapnik-win-sdk-%MAPNIK_VERSION%.zip
7z a mapnik-win-sdk-%MAPNIK_VERSION%.zip %PREFIX%
rd %PREFIX2%\include /s /q
@ rem - note: prefix has c:\\ which screws up del
del c:\mapnik-%MAPNIK_VERSION%\lib\*lib
del mapnik-win-%MAPNIK_VERSION%.zip
7z a mapnik-win-%MAPNIK_VERSION%.zip %PREFIX%
@rem python s3cmd\s3cmd --acl-public put mapnik-win-%MAPNIK_VERSION%.zip s3://mapnik/dist/dev/mapnik-win-%MAPNIK_VERSION%.zip