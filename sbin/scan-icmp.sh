#!/bin/bash
echo "Before running be sure to modify or remove the --interface, --gateway-mac, --source-mac, and --source-ip flags below (and delete this line)." && exit 1

if [ -f /home/jcc/var/run/upgrade.lock ]; then
    echo "upgrade pending; exiting"
    exit 0
fi

function cleanup {
    rm -f /home/jcc/var/run/scan-icmp.lock
}
trap cleanup HUP INT TERM QUIT ABRT FPE ALRM

set -ex
exec 7> /home/jcc/var/run/scan-icmp.lock
if ! flock -n 7  ; then
    echo "$0 is already running." >&2
    exit 1
fi

source /home/jcc/.profile

NOW=$(date +%Y%m%d)

NEW_UUID=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
datadir="/home/jcc/tmp/$NEW_UUID"
mkdir -p "$datadir"
pushd "$datadir"
/home/jcc/opt/sbin/zmap -M icmp_echoscan --interface=dne0 --gateway-mac=00:00:00:00:00:00 --source-mac=00:00:00:00:00:00 --source-ip=0.0.0.0 --output-module=json --output-fields=* --max-sendto-failures=1000 --cooldown-time=300 --blacklist-file=/home/jcc/opt/etc/zmap/blacklist.conf -r 180000 --sender-threads=1 --verbosity=5 --log-file=$NOW.zmap.icmp_echo.log --metadata=$NOW.zmap.icmp_echo.meta --status-updates-file=$NOW.zmap.icmp_echo.status | gzip > $NOW.zmap.icmp_echo.jsonl.gz
chmod 644 *
mv * /datalz-pre
popd
rmdir "$datadir"

rm -f /home/jcc/var/run/scan-icmp.lock
