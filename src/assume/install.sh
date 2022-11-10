#!/bin/sh
set -e

echo "Setting up credential rotation for Role: ${ROLE}"

cp assume.sh /usr/local/bin/assume.sh
chmod +x /usr/local/bin/assume.sh

apt-get -y update
apt-get -y install cron

mkdir -p /etc/cron.d
echo "* * * * * codespaces /usr/local/bin/assume.sh $ROLE" > /etc/cron.d/assume_role