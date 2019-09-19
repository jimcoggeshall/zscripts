#!/bin/bash

set -exo pipefail
exec 1>>/home/jcc/var/log/daq-bgpreader.log 2>&1
source /home/jcc/.profile
export LD_LIBRARY_PATH="/home/jcc/lib:$LD_LIBRARY_PATH"
export LD_RUN_PATH="/home/jcc/lib:$LD_RUN_PATH"
export PATH="/home/jcc/bin:$PATH"

bgpreader -l -w $(date +%s) | multilog t s200000000 n10000 '+*' /home/jcc/var/data/bgpreader
