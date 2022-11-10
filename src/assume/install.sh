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

# Dirty dirty dirty hack to start cron for demonstration purposes
sed -i '$ d' /etc/init.d/ssh
echo "service cron start" >> /etc/init.d/ssh
echo "exit 0" >> /etc/init.d/ssh
