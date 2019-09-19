#!/bin/bash

set -ex
source /home/jcc/.profile

NOW=$(date +%Y%m%d)

NEW_UUID=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
datadir="/home/jcc/tmp/$NEW_UUID"
mkdir -p "$datadir"
pushd "$datadir"
cat /home/jcc/etc/rir.conf | while read f; do
    wget --timeout 10 --tries 2 --recursive $f || :
done

find . -mindepth 2 -type f -exec "echo" {} \; | while read f; do
    dest="$(echo $f | sed -e 's/^\.\///g' -e 's/\//-/g')"
    dest="$NOW.routing_registries.$dest"
    mv "$f" "$dest"
done
find . -mindepth 1 -maxdepth 1 -type d -exec rm -rf {} \;

chmod 644 *
mv * /datalz-pre
popd
rmdir "$datadir"
