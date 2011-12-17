# feed the boost beast
cd ${PACKAGES}/boost*/
mkdir boost-staging
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
boost-staging/ 1>/dev/null
cp -r boost-staging/boost ${MAPNIK_INSTALL}/include/

cp -r ${BUILD}/include/proj_api.h ${MAPNIK_INSTALL}/include/proj_api.h
cp -r ${BUILD}/include/unicode ${MAPNIK_INSTALL}/include/unicode
cp -r ${BUILD}/include/freetype2 ${MAPNIK_INSTALL}/include/freetype2
cp -r ${BUILD}/include/ft2build.h ${MAPNIK_INSTALL}/include/ft2build.h
