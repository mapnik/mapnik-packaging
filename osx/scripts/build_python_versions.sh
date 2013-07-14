set -e 

mkdir -p ${PACKAGES}
cd ${PACKAGES}

# boost python for various versions are done in python script
#python ${ROOTDIR}/scripts/build_boost_pythons.py 2.5 64
#mv stage/lib/libboost_python.dylib stage/lib/libboost_python-2.5.dylib
#cp stage/lib/libboost_python-2.5.dylib ${BUILD}/lib/libboost_python-2.5.dylib
#install_name_tool -id @loader_path/libboost_python-2.5.dylib ${BUILD}/lib/libboost_python-2.5.dylib

echo '*building boost python versions*'

cd ${PACKAGES}/boost_${BOOST_VERSION2}-${ARCH_NAME}
#python ${ROOTDIR}/scripts/build_boost_pythons.py 2.6 64
#mv stage/lib/libboost_python.a stage/lib/libboost_python-2.6.a
#cp stage/lib/libboost_python-2.6.a ${BUILD}/lib/libboost_python-2.6.a
#mv stage/lib/libboost_python.dylib stage/lib/libboost_python-2.6.dylib
#cp stage/lib/libboost_python-2.6.dylib ${BUILD}/lib/libboost_python-2.6.dylib
#install_name_tool -id @loader_path/libboost_python-2.6.dylib ${BUILD}/lib/libboost_python-2.6.dylib

python ${ROOTDIR}/scripts/build_boost_pythons.py 2.6 ${BOOST_TOOLSET} 64 ${BOOST_ARCH}
mv stage/lib/libboost_python.a stage/lib/libboost_python-2.6.a
cp stage/lib/libboost_python-2.6.a ${BUILD}/lib/libboost_python-2.6.a

python ${ROOTDIR}/scripts/build_boost_pythons.py 2.7 ${BOOST_TOOLSET} 64 ${BOOST_ARCH}
mv stage/lib/libboost_python.a stage/lib/libboost_python-2.7.a
cp stage/lib/libboost_python-2.7.a ${BUILD}/lib/libboost_python-2.7.a

#mv stage/lib/libboost_python.dylib stage/lib/libboost_python-2.7.dylib
#cp stage/lib/libboost_python27.dylib ${BUILD}/lib/libboost_python-2.7.dylib
#install_name_tool -id @loader_path/libboost_python-2.7.dylib ${BUILD}/lib/libboost_python-2.7.dylib

# this landed in boost at 1.53 or there-abouts
#patch libs/python/src/converter/builtin_converters.cpp ${PATCHES}/boost_python3k_bytes.diff
python ${ROOTDIR}/scripts/build_boost_pythons.py 3.3 ${BOOST_TOOLSET} 64 ${BOOST_ARCH}
mv stage/lib/libboost_python3.a stage/lib/libboost_python-3.3.a
cp stage/lib/libboost_python-3.3.a ${BUILD}/lib/libboost_python-3.3.a

cd ${PACKAGES}

if [ $UNAME = 'Darwin' ]; then
    # py2cairo
    echo '*building py2cairo*'
    rm -rf py2cairo-${PY2CAIRO_VERSION}
    tar xf py2cairo-${PY2CAIRO_VERSION}.tar.bz2
    cd py2cairo-${PY2CAIRO_VERSION}
    # apply patch
    patch wscript < ${PATCHES}/py2cairo-static.diff
    for i in {"2.6","2.7"}
    do
        PYTHON=python$i ./waf configure --prefix=${BUILD} --nopyc --nopyo
        PYTHON=python$i ./waf install
    done
    cd ${PACKAGES}

    # py3cairo
    echo '*building py3cairo*'
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
cd ${PACKAGES}

