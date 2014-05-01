#!/usr/bin/env bash
set -e -u 

mkdir -p ${PACKAGES}
cd ${PACKAGES}
mkdir -p ${BUILD}/lib/

echoerr 'building boost python versions'

cd ${PACKAGES}/boost_${BOOST_VERSION2}-${ARCH_NAME}

python ${ROOTDIR}/scripts/build_boost_pythons.py 2.7 ${BOOST_TOOLSET} 64 ${BOOST_ARCH} $(which $CXX)
mv stage/lib/libboost_python.a stage/lib/libboost_python-2.7.a
echoerr "placing boost python at ${BUILD}/lib/libboost_python-2.7.a"
cp stage/lib/libboost_python-2.7.a ${BUILD}/lib/libboost_python-2.7.a

if [[ ${OFFICIAL_RELEASE} == true ]]; then
    python ${ROOTDIR}/scripts/build_boost_pythons.py 2.6 ${BOOST_TOOLSET} 64 ${BOOST_ARCH} $(which $CXX)
    mv stage/lib/libboost_python.a stage/lib/libboost_python-2.6.a
    echoerr "placing boost python at ${BUILD}/lib/libboost_python-2.6.a"
    cp stage/lib/libboost_python-2.6.a ${BUILD}/lib/libboost_python-2.6.a
    
    # this landed in boost at 1.53 or there-abouts
    #patch libs/python/src/converter/builtin_converters.cpp ${PATCHES}/boost_python3k_bytes.diff
    python ${ROOTDIR}/scripts/build_boost_pythons.py 3.3 ${BOOST_TOOLSET} 64 ${BOOST_ARCH} $(which $CXX)
    mv stage/lib/libboost_python3.a stage/lib/libboost_python-3.3.a
    echoerr "placing boost python at ${BUILD}/lib/libboost_python-3.3.a"
    cp stage/lib/libboost_python-3.3.a ${BUILD}/lib/libboost_python-3.3.a
fi

cd ${PACKAGES}

