CHROOT_BASE=. # This makes Travis CI environment easier

export COMPILE_ENV="sudo chroot $CHROOT_BASE"

# setup chroot/qemu
sudo apt-get install debootstrap qemu-user-static
sudo debootstrap --foreign --variant=minbase --arch armhf --include=locales testing `pwd`/$CHROOT_BASE http://mirrordirector.raspbian.org/raspbian
sudo cp /usr/bin/qemu-arm-static $CHROOT_BASE/usr/bin/
sudo cp osx/ArmLinux_setup_stage2.sh $CHROOT_BASE/tmp/setup.sh

# enter chroot/qemu
$COMPILE_ENV /tmp/setup.sh
