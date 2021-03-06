#!/usr/bin/env bash

set -e -u
set -o pipefail

rm -rf /tmp/cpp-static-link-test
mkdir -p /tmp/cpp-static-link-test/
cd /tmp/cpp-static-link-test

echo '
#include <string>
std::string hello();
' > lib.hpp

echo '
// C++11 usage
std::string hello_move(std::string && moved);
' >> lib.hpp

echo '
#include "lib.hpp"
std::string hello() {
    return "hello world\n";
}
' > lib.cpp

echo '
// C++11 usage
std::string hello_move(std::string && moved)
{
    return std::move(moved);
}' >> lib.cpp

echo '
#include <iostream>
#include "lib.hpp"
' > test.cpp

echo '
#include <iostream>
#include "lib.hpp"
int main(void) {
    std::cout << hello();
    std::string first("around the world");
    std::string second = hello_move(std::move(first));
    std::cout << second << "\n";
    return 0;
}
' > test.cpp
if [[ $UNAME == 'Linux' ]]; then
   LDFLAGS="${LDFLAGS} -static-libstc++"
   #ln -s `${CXX} ${CXXFLAGS} -print-file-name=libstdc++.a` libstdc++.a
fi

# http://micro.nicholaswilson.me.uk/post/31855915892/rules-of-static-linking-libstdc-libc-libgcc

${CXX} -o test test.cpp lib.cpp -L. ${CXXFLAGS} ${LDFLAGS}
./test
if [[ $UNAME == 'Linux' ]]; then
    ldd ./test
elif [[ $UNAME == 'Darwin' ]]; then
    otool -L ./test
fi

# /usr/bin/ld: /usr/lib/gcc/x86_64-linux-gnu/4.6.1/libstdc++.a(ctype.o): relocation R_X86_64_32S against `vtable for std::ctype<wchar_t>' can not be used when making a shared object; recompile with -fPIC
#/usr/lib/gcc/x86_64-linux-gnu/4.6.1/libstdc++.a: could not read symbols: Bad value
# ln -s /usr/lib/gcc/x86_64-linux-gnu/4.6.1/libstdc++_pic.a `pwd`/libstdc++.a
