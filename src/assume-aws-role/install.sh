#!/bin/sh
set -e

echo "Setting up AWS credentials for role ${ROLE}..."

if [ -z "${ROLE}" ]; then
  echo "Error: role is required"
  exit 1
fi

if [ -z "${REGION}" ]; then
  REGION="us-east-1"
fi

mkdir -p /etc/saml-to/aws
chmod -R +r /etc/saml-to

echo "${ROLE}" > /etc/saml-to/aws/role
chmod +r /etc/saml-to/aws/role

echo "${REGION}" > /etc/saml-to/aws/region
chmod +r /etc/saml-to/aws/region

cp assume-aws-role.sh /usr/local/bin/assume-aws-role
chmod +rx /usr/local/bin/assume-aws-role

echo "Installing Profile Script..."

# Assumption at session start
cat <<EOT >> /etc/profile.d/01-assume-aws-role.sh
#!/bin/sh
/usr/local/bin/assume-aws-role
EOT
chmod +rx /etc/profile.d/01-assume-aws-role.sh

echo "Setting up Credential Refreshes using Cron..."

# Re-assumption using Cron
# TODO set credentials globally for all users, unhardcode 'codespace'
cat <<EOT >> /etc/cron.d/assume-aws-role
*/30 * * * * root sudo -S -i -u codespace /usr/local/bin/assume-aws-role | tee -a /tmp/cron.log > /dev/null
EOT
chmod +r /etc/cron.d/assume-aws-role

echo "Installing Cron..."
# TODO use saml-to cli in daemon mode
# TODO or VSCode plugin of somekind
apt-get update
apt-get -y install --no-install-recommends cron
rm -rf /var/lib/apt/lists/*

cp cron-init.sh /usr/local/share/cron-init.sh
chmod +rx /usr/local/share/cron-init.sh
