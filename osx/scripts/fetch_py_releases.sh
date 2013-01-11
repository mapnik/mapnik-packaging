# http://www.python.org/download/releases/
# http://www.python.org/ftp/python/

# 2.5.4 (2.5.5 did not provide binaries)
wget http://www.python.org/ftp/python/2.5.4/python-2.5.4-macosx.dmg

# 2.6.6
wget http://www.python.org/ftp/python/2.6.6/python-2.6.6-macosx10.3.dmg

# 2.7
wget http://www.python.org/ftp/python/2.7.2/python-2.7.2-macosx10.6.dmg

# 3.1.x does not provide 64 bit versions for some reasons, so skip...
#wget http://www.python.org/ftp/python/3.1.3/python-3.1.3-macosx10.3.dmg
#wget http://www.python.org/ftp/python/3.1.2/Python-3.1.2.tar.bz2

# 3.2
#wget http://www.python.org/ftp/python/3.2.2/python-3.2.2-macosx10.6.dmg
#hdiutil mount python-3.2.2-macosx10.6.dmg
#sudo installer -package "/Volumes/Python 3.2.2/Python.mpkg" -target "/Volumes/Macintosh HD"

# 3.3
wget http://www.python.org/ftp/python/3.3.0/python-3.3.0-macosx10.6.dmg
hdiutil mount python-3.3.0-macosx10.6.dmg
sudo installer -package "/Volumes/Python 3.3.0/Python.mpkg" -target "/Volumes/Macintosh HD"