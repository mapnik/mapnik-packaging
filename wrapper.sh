#!/bin/bash

echo "Sourcing build.sh for build functions ..."
source ./build.sh

echo "Running '${TARGET}' as build target ..."
${TARGET}
