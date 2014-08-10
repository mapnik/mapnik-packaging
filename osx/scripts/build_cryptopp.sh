#!/usr/bin/env bash
set -e -u
set -o pipefail
mkdir -p ${PACKAGES}
cd ${PACKAGES}

# http://www.cryptopp.com/#download
CRYPTOPP_VERSION="562"
download cryptopp${CRYPTOPP_VERSION}.zip

echoerr 'building cryptopp'
rm -rf cryptopp${CRYPTOPP_VERSION}
unzip -d cryptopp${CRYPTOPP_VERSION} cryptopp${CRYPTOPP_VERSION}.zip
cd cryptopp${CRYPTOPP_VERSION}
# -DCRYPTOPP_DISABLE_ASM needed due to 'gcm.cpp:746:3: error: invalid instruction mnemonic 'prefix''
# -Wno-c++11-narrowing needed due to 'wake.cpp:28:3: error: constant expression evaluates to 3868867420 which cannot be narrowed to type 'int''
$MAKE -j${JOBS} CC="${CC}" CXX="${CXX}" CXXFLAGS="${CXXFLAGS} -DCRYPTOPP_DISABLE_ASM -Wno-c++11-narrowing" LDFLAGS="${LDFLAGS}"
$MAKE install PREFIX=${BUILD}
cd ${PACKAGES}
