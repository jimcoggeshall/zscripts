#!/bin/bash

if [ -f /home/jcc/var/run/upgrade.lock ]; then
    echo "upgrade pending; exiting"
    exit 0
fi

function cleanup {
    mv /home/jcc/tmp/bgpreader-* /datalz-pre/
}
trap cleanup HUP INT TERM QUIT ABRT FPE ALRM

set -exo pipefail
NOW=$(date +%Y%m%d%H)
exec 1>/home/jcc/var/log/$NOW.rotate-bgpreader.log 2>&1
source /home/jcc/.profile

NEW_UUID=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1) || :
datadir="/home/jcc/tmp/bgpreader-$NEW_UUID"
mkdir -p "$datadir"
pushd "$datadir"
echo -n "" > "$NOW.bgpstream.dat"
find /home/jcc/var/data/bgpreader -type f -name '@*.s' -exec echo '{}' \; | while read f; do
    mv "$f" . 
done
find . -type f -name '@*.s' -exec echo '{}' \; | while read f; do
    cat "$f" >> "$NOW.bgpstream.dat"
    rm "$f"
done
chmod 644 "$NOW.bgpstream.dat"
mv "$NOW.bgpstream.dat" /datalz-pre/
popd
rmdir "$datadir"
