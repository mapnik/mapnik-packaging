#!/bin/bash



if test -e "/Library/Frameworks/Mapnik.framework"; then rm -r "/Library/Frameworks/Mapnik.framework"; fi
set +e
pkgutil --forget mapnik.org.Mapnik.pkg > /dev/null 2>&1 || true
pkgutil --forget mapnik.org.uninstall.pkg
set -e
if test -e "/Library/Python/2.6/site-packages/mapnik.pth"; then rm "/Library/Python/2.6/site-packages/mapnik.pth"; fi
if test -e "/Library/Python/2.7/site-packages/mapnik.pth"; then rm "/Library/Python/2.7/site-packages/mapnik.pth"; fi
if test -e "/etc/paths.d/mapnik"; then rm "/etc/paths.d/mapnik"; fi

