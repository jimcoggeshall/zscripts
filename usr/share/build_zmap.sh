#!/bin/bash

set -ex
source $HOME/.profile

sudo apt update && sudo apt -y dist-upgrade
mkdir -p $HOME/var/zmap
pushd $HOME/var/zmap
git pull
cmake -DCMAKE_INSTALL_PREFIX=$HOME/opt -DENABLE_DEVELOPMENT=OFF -DENABLE_LOG_TRACE=OFF -DRESPECT_INSTALL_PREFIX_CONFIG=ON -DFORCE_CONF_INSTALL=ON .
make -B
make -B install
sudo setcap cap_net_raw+epi $HOME/opt/sbin/zmap
