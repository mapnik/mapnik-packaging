#!/bin/bash

# finish debootstrap process
./debootstrap/debootstrap --second-stage
export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true
cat <<'EOF' > /tmp/preseed.txt
locales locales/locales_to_be_generated multiselect "en_US.UTF-8 UTF-8"
locales locales/default_environment_locale select en_US.UTF-8
tzdata tzdata/Areas select US
tzdata tzdata/Zones/US select Central
EOF
debconf-set-selections /tmp/preseed.txt
dpkg-reconfigure tzdata locales

# set up apt-get
echo "deb http://mirrordirector.raspbian.org/raspbian/ jessie main contrib non-free rpi" > /etc/apt/sources.list

apt-get update
apt-get install -q -y lsb-release wget

# mount proc for 'free'
mount proc /proc -t proc
