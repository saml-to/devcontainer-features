#!/bin/sh
set -e

echo "Setting up credential rotation for Role: ${ROLE}"

cp assume.sh /usr/local/bin/assume.sh
chmod +rx /usr/local/bin/assume.sh

cp assumer.sh /usr/local/bin/assumer.sh
chmod +rx /usr/local/bin/assumer.sh

/usr/local/bin/assumer.sh codespace ${ROLE} &
