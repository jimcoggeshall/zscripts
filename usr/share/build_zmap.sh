#!/bin/bash

set -ex
source /home/jcc/.profile

sudo apt update && sudo apt -y dist-upgrade
pushd /home/jcc/var/zmap
git pull
cmake -DCMAKE_INSTALL_PREFIX=/home/jcc/opt -DENABLE_DEVELOPMENT=OFF -DENABLE_LOG_TRACE=OFF -DRESPECT_INSTALL_PREFIX_CONFIG=ON -DFORCE_CONF_INSTALL=ON .
make -B
make -B install
sudo setcap cap_net_raw+epi /home/jcc/opt/sbin/zmap
