#!/bin/sh
set -e

echo "Setting up credential rotation for Role: ${ROLE}"

cp assume.sh /usr/local/bin/assume.sh
chmod +rx /usr/local/bin/assume.sh

cp assumer.sh /usr/local/bin/assumer.sh
chmod +rx /usr/local/bin/assumer.sh

apt-get -y update
apt-get -y install cron

echo "* * * * * root /usr/local/bin/assumer.sh codespace ${ROLE}" > /etc/cron.d/assume

service cron start
