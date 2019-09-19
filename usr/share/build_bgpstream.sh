#!/bin/bash

set -ex
source /home/jcc/.profile

sudo apt update && sudo apt -y dist-upgrade
pushd /home/jcc/var/wandio
git pull
./configure --prefix=/home/jcc
make
make install
popd

pushd /home/jcc/var/bgpstream
git pull
./autogen.sh
./configure --prefix=/home/jcc CPPFLAGS='-I/home/jcc/include' LDFLAGS='-L/home/jcc/lib'
make
make install
popd
