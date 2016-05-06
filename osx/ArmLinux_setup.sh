CHROOT_BASE=. # This makes Travis CI environment easier

MASON_PLATFORM=${MASON_PLATFORM-ArmLinux}
CXX11=${CXX11-true}
TARGET=${TARGET-build_mapnik}
QUIET=${QUIET-true}
MAPNIK_BRANCH=${MAPNIK_BRANCH-master}

# select g++/gcc here because upgrade_(compiler) is called before platorm script
CXX=g++
CC=gcc

export COMPILE_ENV="sudo chroot $CHROOT_BASE /usr/bin/env MASON_PLATFORM=${MASON_PLATFORM} CXX11=${CXX11} TARGET=${TARGET} QUIET=${QUIET} MAPNIK_BRANCH=${MAPNIK_BRANCH} CXX=${CXX} CC=${CC}"

# setup chroot/qemu
sudo apt-get install debootstrap qemu-user-static
sudo debootstrap --foreign --variant=minbase --arch armhf --include=locales testing `pwd`/$CHROOT_BASE http://mirrordirector.raspbian.org/raspbian
sudo cp /usr/bin/qemu-arm-static $CHROOT_BASE/usr/bin/
sudo cp osx/ArmLinux_setup_stage2.sh $CHROOT_BASE/tmp/setup.sh
sudo cp osx/ArmLinux_fake_sudo.sh $CHROOT_BASE/usr/bin/sudo

# enter chroot/qemu
$COMPILE_ENV /tmp/setup.sh
