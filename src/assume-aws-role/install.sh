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

if [ -z "${PROFILE}" ]; then
  PROFILE="default"
fi

mkdir -p /workspaces/.codespaces/shared/.saml-to
chmod +r /workspaces/.codespaces/shared/.saml-to

echo "${ROLE}" > /workspaces/.codespaces/shared/.saml-to/aws-role
chmod +r /workspaces/.codespaces/shared/.saml-to/aws-role

echo "${REGION}" > /workspaces/.codespaces/shared/.saml-to/aws-region
chmod +r /workspaces/.codespaces/shared/.saml-to/aws-region

echo "${PROFILE}" > /workspaces/.codespaces/shared/.saml-to/aws-profile
chmod +r /workspaces/.codespaces/shared/.saml-to/aws-profile

cp assume-aws-role.sh /usr/local/bin/assume-aws-role.sh
chmod +rx /usr/local/bin/assume-aws-role.sh

echo "Installing Profile Script..."

# Assumption at session start
# cat <<EOT >> /etc/profile.d/01-assume-aws-role.sh
# #!/bin/sh
# /usr/local/bin/assume-aws-role.sh
# EOT
# chmod +rx /etc/profile.d/01-assume-aws-role.sh

echo "Setting up Credential Refreshes using Cron..."

# Re-assumption using Cron
# TODO switch to use credentials from /workspaces/.codespaces/shared/.env-secrets
# TODO set credentials globally for all users, unhardcode 'codespace'
# TODO switch to every 30 minutes
cat <<EOT >> /etc/cron.d/assume-aws-role
* * * * * root sudo -S -i -u codespace /usr/local/bin/assume-aws-role.sh
EOT
chmod +r /etc/cron.d/assume-aws-role

echo "Installing Cron..."
# TODO use saml-to cli in daemon mode
apt-get update
apt-get -y install --no-install-recommends cron
rm -rf /var/lib/apt/lists/*
