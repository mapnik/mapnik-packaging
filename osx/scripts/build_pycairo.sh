#!/bin/bash
set -e -u 

mkdir -p ${PACKAGES}
cd ${PACKAGES}
mkdir -p ${BUILD}/lib/

echoerr 'building pycairo'

if [ $UNAME = 'Darwin' ]; then

    download py2cairo-${PY2CAIRO_VERSION}.tar.bz2

    echoerr 'building py2cairo for py2.7'
    rm -rf py2cairo-${PY2CAIRO_VERSION}
    tar xf py2cairo-${PY2CAIRO_VERSION}.tar.bz2
    cd py2cairo-${PY2CAIRO_VERSION}
    # apply patch
    patch wscript < ${PATCHES}/py2cairo-static.diff
    PYTHON=python2.7 ./waf configure --prefix=${BUILD} --nopyc --nopyo
    PYTHON=python2.7 ./waf install
    cd ${PACKAGES}

    if [[ ${OFFICIAL_RELEASE} == true ]]; then
        # py2cairo
        echoerr 'building py2cairo for py2.6'
        rm -rf py2cairo-${PY2CAIRO_VERSION}
        tar xf py2cairo-${PY2CAIRO_VERSION}.tar.bz2
        cd py2cairo-${PY2CAIRO_VERSION}
        # apply patch
        patch wscript < ${PATCHES}/py2cairo-static.diff
        PYTHON=python2.6 ./waf configure --prefix=${BUILD} --nopyc --nopyo
        PYTHON=python2.6 ./waf install
        cd ${PACKAGES}
    
        # py3cairo
        download pycairo-${PY3CAIRO_VERSION}.tar.bz2
        
        echoerr 'building py3cairo for py3.3'
        rm -rf pycairo-${PY3CAIRO_VERSION}
        tar xf pycairo-${PY3CAIRO_VERSION}.tar.bz2
        cd pycairo-${PY3CAIRO_VERSION}
        # apply patch
        patch wscript < ${PATCHES}/py3cairo-static.diff
    
        if [ $UNAME = 'Darwin' ]; then
            export PATH=/Library/Frameworks/Python.framework/Versions/3.3/bin/:$PATH
        fi
    
        for i in {"3.3",}
        do
            PYTHON=python$i ./waf configure --prefix=${BUILD} --nopyc --nopyo
            PYTHON=python$i ./waf install
        done
    
    fi
fi

cd ${PACKAGES}

