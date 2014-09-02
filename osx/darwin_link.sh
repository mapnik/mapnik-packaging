#!/usr/bin/env bash

export ROOTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

OUTPUT="${ROOTDIR}/out/build-cpp11-libcpp-universal"

if [ -d ${OUTPUT} ] && [ ! -L ${OUTPUT} ]; then
    mv ${OUTPUT} "${ROOTDIR}/out/universal"
elif [ -L ${OUTPUT} ]; then
    rm ${OUTPUT}
fi

if [ "$1" = "ios" ]; then
    ln -s "${ROOTDIR}/out/universal" ${OUTPUT}
else
    ln -s "${ROOTDIR}/out/build-cpp11-libcpp-x86_64-macosx" ${OUTPUT}
fi
