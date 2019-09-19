#!/bin/bash
echo "Before running be sure to modify or remove the --interface, --gateway-mac, --source-mac, and --source-ip flags below (and delete this line)." && exit 1

if [ -f /home/jcc/var/run/upgrade.lock ]; then
    echo "upgrade pending; exiting"
    exit 0
fi

function cleanup {
    rm -f /home/jcc/var/run/scan-heavy.lock
    rm -f /home/jcc/var/run/scan-https.lock
}
trap cleanup HUP INT TERM QUIT ABRT FPE ALRM

set -ex
exec 9> /home/jcc/var/run/scan-heavy.lock
exec 8> /home/jcc/var/run/scan-https.recent
exec 7> /home/jcc/var/run/scan-https.lock
if ! flock -n 9  ; then
    echo "Heavy scan is already running." >&2
    exit 1
fi
if ! flock -n 8  ; then
    echo "$0 is recent heavy scan." >&2
    exit 1
fi
if ! flock -n 7  ; then
    echo "$0 is already running." >&2
    exit 1
fi

source /home/jcc/.profile

NOW=$(date +%Y%m%d)

NEW_UUID=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1) || :
datadir="/home/jcc/tmp/$NEW_UUID"
mkdir -p "$datadir"
pushd "$datadir"
/home/jcc/opt/sbin/zmap -p 443 --interface=dne0 --gateway-mac=00:00:00:00:00:00 --source-mac=00:00:00:00:00:00 --source-ip=0.0.0.0 --output-module=csv --output-fields=* --max-sendto-failures=1000 --cooldown-time=30 --blacklist-file=/home/jcc/opt/etc/zmap/blacklist.conf -r 200000000 --sender-threads=1  --verbosity=5 --log-file=$NOW.zmap.https_banners.log --metadata=$NOW.zmap.https_banners.meta --status-updates-file=$NOW.zmap.https_banners.status | /home/jcc/opt/sbin/ztee --success-only --status-updates-file=$NOW.ztee.https_banners.status $NOW.ztee.https_banners.csv | /home/jcc/go/bin/zgrab --port 443 --tls --http="/" --http-max-redirects=2 --http-max-size=256 --gomaxprocs=16 2> $NOW.zgrab.https_banners.out | gzip > $NOW.zgrab.https_banners.jsonl.gz
chmod 644 *
mv * /datalz-pre
popd
rmdir "$datadir"

rm -f /home/jcc/var/run/scan-heavy.lock
rm -f /home/jcc/var/run/scan-https.lock
mv /home/jcc/var/run/scan-https.recent /home/jcc/var/run/scan-https.recent.t
rm -f /home/jcc/var/run/*.recent
mv /home/jcc/var/run/scan-https.recent.t /home/jcc/var/run/scan-https.recent
