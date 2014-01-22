#!/bin/bash
set -e -u

echo '...copying headers needed for node bindings to compile against mapnik'

# feed the boost beast - 45 MB instead of 113
cd ${PACKAGES}/boost*/
mkdir -p boost-staging
./dist/bin/bcp \
boost/thread/mutex.hpp \
boost/regex.hpp \
boost/unordered_map.hpp \
boost/make_shared.hpp \
boost/variant.hpp \
boost/algorithm/string.hpp \
boost/spirit/include/qi.hpp \
boost/spirit/include/qi_action.hpp \
boost/ptr_container/ptr_vector.hpp \
boost/property_map/property_map.hpp \
boost/math/constants/constants.hpp \
boost/spirit/include/phoenix_operator.hpp \
boost/spirit/include/phoenix_fusion.hpp \
boost/fusion/include/adapt_struct.hpp \
boost/fusion/include/adapt_adt.hpp \
boost/property_tree/ptree.hpp \
boost/any.hpp \
boost/optional.hpp \
boost/interprocess/mapped_region.hpp \
boost/multi_index/ordered_index.hpp \
boost-staging/ 1>/dev/null
cp -r boost-staging/boost ${MAPNIK_BIN_SOURCE}/include/

cp -r ${BUILD}/include/proj_api.h ${MAPNIK_BIN_SOURCE}/include/proj_api.h
cp -r ${BUILD}/include/unicode ${MAPNIK_BIN_SOURCE}/include/
cp -r ${BUILD}/include/freetype2 ${MAPNIK_BIN_SOURCE}/include/
cp -r ${BUILD}/include/ft2build.h ${MAPNIK_BIN_SOURCE}/include/ft2build.h

# if cairo is installed
if [ -f ${BUILD}/include/cairo/cairo.h ]; then
    cp -r ${BUILD}/include/cairo ${MAPNIK_BIN_SOURCE}/include/
    cp -r ${BUILD}/include/fontconfig ${MAPNIK_BIN_SOURCE}/include/
fi
