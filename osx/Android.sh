export PLATFORM="Android"
export BOOST_ARCH="arm"
export ARCH_NAME="gcc-arm"
export HOST_ARG="--host=arm-linux-androideabi"
source settings.sh

function run {
  emulator -avd Phone & ddms
}