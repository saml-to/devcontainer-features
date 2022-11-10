#!/bin/sh
set -e

echo "Setting up credential rotation for Role: ${ROLE}"

cp assume.sh /usr/local/bin/assume.sh
chmod +rx /usr/local/bin/assume.sh

cat <<EOT >> /etc/profile.d/01-assume.sh
#!/bin/sh
/usr/local/bin/assume.sh ${ROLE}
EOT
chmod +rx /etc/profile.d/01-assume.sh
