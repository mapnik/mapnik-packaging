#!/usr/bin/env bash

: '
setup environment for building against mapnik in the
location that `./scripts/build_mapnik.sh` installs things

usage:

    source mapnikenv.sh

'

if [[ $(uname -s) == 'Darwin' ]]; then
    source $(dirname "$BASH_SOURCE")/osx/MacOSX.sh
else
    source $(dirname "$BASH_SOURCE")/osx/Linux.sh
fi

if [[ -d ${MAPNIK_BIN_SOURCE} ]]; then
    if [[ $(uname -s) == 'Darwin' ]]; then
        export DYLD_LIBRARY_PATH="${MAPNIK_BIN_SOURCE}/lib"
    else
        export LD_LIBRARY_PATH="${MAPNIK_BIN_SOURCE}/lib";
    fi

    export LIBRARY_PATH="${MAPNIK_BIN_SOURCE}/lib"
    export C_INCLUDE_PATH="${MAPNIK_BIN_SOURCE}/include"
    export CPLUS_INCLUDE_PATH="${MAPNIK_BIN_SOURCE}/include"
    export PATH="${MAPNIK_BIN_SOURCE}/bin:${PATH}"
else
    echo "Error mapnik build directory does not exist:"
    echo "    ${MAPNIK_BIN_SOURCE}"
    echo "Please run:"
    echo "    cd $(dirname "$BASH_SOURCE")"
    if [[ $(uname -s) == 'Darwin' ]]; then
        echo "    source ~/MacOSX.sh"
    else
        echo "    source ~/Linux.sh"
    fi
    echo "    ./scripts/build_mapnik.sh"

fi