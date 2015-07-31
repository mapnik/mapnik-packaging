#!/usr/bin/env bash
set -e -u
set -o pipefail

echoerr 'Building mapnik'
cd ${MAPNIK_SOURCE}
if [[ ${OFFICIAL_RELEASE} != true ]]; then
    git pull
fi

if [ -d ${MAPNIK_BIN_SOURCE} ]; then
  rm -rf ${MAPNIK_BIN_SOURCE}
  rm -f ${MAPNIK_SOURCE}/src/libmapnik{*.so,*.dylib,*.a}
  rm -f ${MAPNIK_SOURCE}/test/*/*-bin
  rm -f ${MAPNIK_SOURCE}/test/unit/run
  rm -f ${MAPNIK_SOURCE}/benchmark/out/*
  # TODO: https://github.com/mapnik/mapnik/issues/2112
  #$MAKE clean
fi

if [[ "${TRAVIS_COMMIT:-false}" != false ]]; then
   JOBS=2
fi

echo "PREFIX = '${MAPNIK_INSTALL}'" > config.py
echo "DESTDIR = '${MAPNIK_DESTDIR}'" >> config.py
echo "CXX = '${CXX}'" >> config.py
echo "CC = '${CC}'" >> config.py
if [ ${BOOST_ARCH} = "x86" ]; then
    echo "CUSTOM_CXXFLAGS = '${CXXFLAGS} ${ICU_CORE_CPP_FLAGS}'" >> config.py
else
    echo "CUSTOM_CXXFLAGS = '${CXXFLAGS} ${ICU_EXTRA_CPP_FLAGS}'" >> config.py
fi
echo "CUSTOM_CFLAGS = '${CFLAGS}'" >> config.py
if [[ ${UNAME} = 'Linux' ]]; then
  # NOTE: --no-undefined works with linux linker to ensure that
  # an error is throw if any symbols cannot be resolve for static libs
  # which can happen if their order is incorrect when linked: see lorder | tsort
  # TODO: only apply this to libmapnik (not python bindings) -Wl,--no-undefined
  echo "CUSTOM_LDFLAGS = '${STDLIB_LDFLAGS} ${LDFLAGS} -Wl,-z,origin -Wl,-rpath=\\\$\$ORIGIN'" >> config.py
else
  echo "CUSTOM_LDFLAGS = '${STDLIB_LDFLAGS} ${LDFLAGS}'" >> config.py
fi
echo "OPTIMIZATION = '${OPTIMIZATION}'" >> config.py
echo "RUNTIME_LINK = 'static'" >> config.py
echo "PATH = '${BUILD}/bin/'" >> config.py
echo "BOOST_INCLUDES = '${BUILD}/include'" >> config.py
echo "BOOST_LIBS = '${BUILD}/lib'" >> config.py
echo "FREETYPE_CONFIG = '${BUILD}/bin/freetype-config'" >> config.py
echo "ICU_INCLUDES = '${BUILD}/include'" >> config.py
echo "ICU_LIBS = '${BUILD}/lib'" >> config.py
echo "PNG_INCLUDES = '${BUILD}/include'" >> config.py
echo "PNG_LIBS = '${BUILD}/lib'" >> config.py
echo "JPEG_INCLUDES = '${BUILD}/include'" >> config.py
echo "JPEG_LIBS = '${BUILD}/lib'" >> config.py
echo "TIFF_INCLUDES = '${BUILD}/include'" >> config.py
echo "TIFF_LIBS = '${BUILD}/lib'" >> config.py
echo "SQLITE_INCLUDES = '${BUILD}/include'" >> config.py
echo "SQLITE_LIBS = '${BUILD}/lib'" >> config.py
echo "PROJ_INCLUDES = '${BUILD}/include'" >> config.py
echo "PROJ_LIBS = '${BUILD}/lib'" >> config.py
echo "CAIRO_INCLUDES = '${BUILD}/include'" >> config.py
echo "CAIRO_LIBS = '${BUILD}/lib'" >> config.py
echo "PATH_REMOVE = '/usr/:/usr/local/'" >> config.py
echo "INPUT_PLUGINS = 'all'" >> config.py
echo "FAST = True" >> config.py
echo "DEMO = False" >> config.py
echo "PGSQL2SQLITE = False" >> config.py
echo "SVG2PNG = False" >> config.py
echo "SAMPLE_INPUT_PLUGINS=False" >> config.py
echo "CPP_TESTS=False" >> config.py
echo "BENCHMARK=False" >> config.py
echo "FULL_LIB_PATH = False" >> config.py
echo "ENABLE_SONAME = False" >> config.py
echo "XMLPARSER = 'ptree'" >> config.py

MAPNIK_BINDINGS=""
if [[ "${MINIMAL_MAPNIK:-false}" != false ]]; then
    echo "SVG_RENDERER = False" >> config.py
    echo "CAIRO = False" >> config.py
else
    echo "SVG_RENDERER = True" >> config.py
    echo "CAIRO = True" >> config.py
fi

if [[ $BOOST_ARCH == "arm" ]]; then
    HOST_ARGS='HOST=${ARCH_NAME}'
    echo "BINDINGS = ''" >> config.py
    echo "LINKING = 'static'" >> config.py
    echo "PLUGIN_LINKING = 'static'" >> config.py
    MAPNIK_BINDINGS=""
else
    HOST_ARGS=""
fi

echo "BINDINGS = '${MAPNIK_BINDINGS}'" >> config.py

set_dl_path "${SHARED_LIBRARY_PATH}"
LIBRARY_PATH="${SHARED_LIBRARY_PATH}" ./configure ${HOST_ARGS}
if [[ ${CXX11} == true ]]; then
  # single job compiles first
  LIBRARY_PATH="${SHARED_LIBRARY_PATH}" python scons/scons.py -j1 \
    --config=cache --implicit-cache --max-drift=1 \
    src/renderer_common/process_group_symbolizer.os \
    src/json/libmapnik-json.a \
    src/wkt/libmapnik-wkt.a \
    src/css_color_grammar.os \
    src/expression_grammar.os \
    src/transform_expression_grammar.os \
    src/image_filter_types.os \
    src/agg/process_markers_symbolizer.os \
    src/agg/process_group_symbolizer.os \
    src/grid/process_markers_symbolizer.os \
    src/grid/process_group_symbolizer.os \
    src/cairo/process_markers_symbolizer.os \
    src/cairo/process_group_symbolizer.os \
    plugins/input/geojson/large_geojson_featureset.os \
    plugins/input/geojson/geojson_datasource.os || true
  # try a second time in the case of a killed compile
  LIBRARY_PATH="${SHARED_LIBRARY_PATH}" python scons/scons.py -j1 \
    --config=cache --implicit-cache --max-drift=1 \
    src/renderer_common/process_group_symbolizer.os \
    src/json/libmapnik-json.a \
    src/wkt/libmapnik-wkt.a \
    src/css_color_grammar.os \
    src/expression_grammar.os \
    src/transform_expression_grammar.os \
    src/image_filter_types.os \
    src/agg/process_markers_symbolizer.os \
    src/agg/process_group_symbolizer.os \
    src/grid/process_markers_symbolizer.os \
    src/grid/process_group_symbolizer.os \
    src/cairo/process_markers_symbolizer.os \
    src/cairo/process_group_symbolizer.os \
    plugins/input/geojson/large_geojson_featureset.os \
    plugins/input/geojson/geojson_datasource.os || true
  # try a third time in the case of a killed compile
  LIBRARY_PATH="${SHARED_LIBRARY_PATH}" python scons/scons.py -j1 \
    --config=cache --implicit-cache --max-drift=1 \
    src/renderer_common/process_group_symbolizer.os \
    src/json/libmapnik-json.a \
    src/wkt/libmapnik-wkt.a \
    src/css_color_grammar.os \
    src/expression_grammar.os \
    src/transform_expression_grammar.os \
    src/image_filter_types.os \
    src/agg/process_markers_symbolizer.os \
    src/agg/process_group_symbolizer.os \
    src/grid/process_markers_symbolizer.os \
    src/grid/process_group_symbolizer.os \
    src/cairo/process_markers_symbolizer.os \
    src/cairo/process_group_symbolizer.os \
    plugins/input/geojson/large_geojson_featureset.os \
    plugins/input/geojson/geojson_datasource.os
fi
# then build the rest
LIBRARY_PATH="${SHARED_LIBRARY_PATH}" JOBS=${JOBS} $MAKE
$MAKE install

$ROOTDIR/scripts/post_build_fix.sh

unset_dl_path


# remove headers for now
#rm -rf ${MAPNIK_BIN_SOURCE}/include
