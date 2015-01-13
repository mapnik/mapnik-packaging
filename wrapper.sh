#!/bin/bash

echo "Initial environment:"
env

echo "Sourcing build.sh for build functions ..."
source ./build.sh

echo "Post-build.sh environment:"
env

echo "Running '${TARGET}' as build target ..."
${TARGET}
