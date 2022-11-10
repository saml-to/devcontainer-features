#!/bin/sh

echo "Starting Assumer Daemon..."

while true; do
  sudo -S -i -u $1 /usr/local/bin/assume.sh $2 || true
  sleep 60
done