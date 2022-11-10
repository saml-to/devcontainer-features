#!/bin/sh
set -e

echo "Setting up credential rotation for Role: ${ROLE}"

cp assume.sh /usr/local/bin/assume.sh
chmod +rx /usr/local/bin/assume.sh

cp assumer.sh /usr/local/bin/assumer.sh
chmod +rx /usr/local/bin/assumer.sh

apt-get -y update
apt-get -y install cron

# DIRTY HACK TO ENABLE CRON
cp 00-enable-cron.sh /etc/profile.d/00-enable-cron.sh
chmod +rx /etc/profile.d/00-enable-cron.sh

echo "* * * * * root /usr/local/bin/assumer.sh codespace ${ROLE}" > /etc/cron.d/assume

