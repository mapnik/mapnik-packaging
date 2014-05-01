Scripts used to package Mapnik on OS X and (experimentally) Linux.

Contact Dane (dane@dbsgeo.com) with any questions.

## linux setup

    apt-get install -y build-essential unzip python-dev \
      git libtool g++ autotools-dev automake cmake make xutils-dev

## osx

    brew install autoconf automake libtool makedepend

## freebsd

Testing with this setup: https://gist.github.com/springmeyer/fabd05d5535e086d5d51

    pkg install git vim gmake python clang34 bash autoconf automake libtool cmake makedepend