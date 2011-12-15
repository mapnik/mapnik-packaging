#!/bin/bash

echo "import sys; sys.path.insert(0,'/Library/Frameworks/Mapnik.framework/unix/lib/python2.6/site-packages/')" > /Library/Python/2.6/site-packages/mapnik.pth
echo "import sys; sys.path.insert(0,'/Library/Frameworks/Mapnik.framework/unix/lib/python2.7/site-packages/')" > /Library/Python/2.7/site-packages/mapnik.pth
# http://hea-www.harvard.edu/~fine/OSX/path_helper.html
echo "/Library/Frameworks/Mapnik.framework/unix/bin" > /etc/paths.d/mapnik
