export PLATFORM="Linux"
export BOOST_ARCH="x86"
export ARCH_NAME="gcc-x86_64"
export HOST_ARG=""
if [ "${CXX11}" != true ]; then
  export CXX11=false
fi
source settings.sh