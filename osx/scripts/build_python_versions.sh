set -e 

mkdir -p ${PACKAGES}
cd ${PACKAGES}
mkdir -p ${BUILD}/lib/

echo '*building boost python versions*'

cd ${PACKAGES}/boost_${BOOST_VERSION2}-${ARCH_NAME}

python ${ROOTDIR}/scripts/build_boost_pythons.py 2.7 ${BOOST_TOOLSET} 64 ${BOOST_ARCH}
mv stage/lib/libboost_python.a stage/lib/libboost_python-2.7.a
echo "placing boost python at ${BUILD}/lib/libboost_python-2.7.a"
cp stage/lib/libboost_python-2.7.a ${BUILD}/lib/libboost_python-2.7.a

if [ $OFFICIAL_RELEASE = 'true' ]; then
    python ${ROOTDIR}/scripts/build_boost_pythons.py 2.6 ${BOOST_TOOLSET} 64 ${BOOST_ARCH}
    mv stage/lib/libboost_python.a stage/lib/libboost_python-2.6.a
    echo "placing boost python at ${BUILD}/lib/libboost_python-2.6.a"
    cp stage/lib/libboost_python-2.6.a ${BUILD}/lib/libboost_python-2.6.a
    
    # this landed in boost at 1.53 or there-abouts
    #patch libs/python/src/converter/builtin_converters.cpp ${PATCHES}/boost_python3k_bytes.diff
    python ${ROOTDIR}/scripts/build_boost_pythons.py 3.3 ${BOOST_TOOLSET} 64 ${BOOST_ARCH}
    mv stage/lib/libboost_python3.a stage/lib/libboost_python-3.3.a
    echo "placing boost python at ${BUILD}/lib/libboost_python-3.3.a"
    cp stage/lib/libboost_python-3.3.a ${BUILD}/lib/libboost_python-3.3.a
fi
    
cd ${PACKAGES}

if [ $UNAME = 'Darwin' ]; then

    echo '*building py2cairo for py2.7*'
    rm -rf py2cairo-${PY2CAIRO_VERSION}
    tar xf py2cairo-${PY2CAIRO_VERSION}.tar.bz2
    cd py2cairo-${PY2CAIRO_VERSION}
    # apply patch
    patch wscript < ${PATCHES}/py2cairo-static.diff
    PYTHON=python2.7 ./waf configure --prefix=${BUILD} --nopyc --nopyo
    PYTHON=python2.7 ./waf install
    cd ${PACKAGES}

    if [ $OFFICIAL_RELEASE = 'true' ]; then
        # py2cairo
        echo '*building py2cairo for py2.6*'
        rm -rf py2cairo-${PY2CAIRO_VERSION}
        tar xf py2cairo-${PY2CAIRO_VERSION}.tar.bz2
        cd py2cairo-${PY2CAIRO_VERSION}
        # apply patch
        patch wscript < ${PATCHES}/py2cairo-static.diff
        PYTHON=python2.6 ./waf configure --prefix=${BUILD} --nopyc --nopyo
        PYTHON=python2.6 ./waf install
        cd ${PACKAGES}
    
        # py3cairo
        echo '*building py3cairo for py3.3*'
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

