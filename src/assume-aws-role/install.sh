#!/bin/sh
set -e

echo "Setting up AWS credentials..."

# TODO Install saml-to CLI

mkdir -p /etc/saml-to/aws
chmod -R +r /etc/saml-to

if [ -n "${ORG}" ]; then
  echo "${ORG}" > /etc/saml-to/org
  chmod +r /etc/saml-to/org
fi

if [ -n "${PROVIDER}" ]; then
  echo "${PROVIDER}" > /etc/saml-to/provider
  chmod +r /etc/saml-to/provider
fi

if [ -n "${ROLE}" ]; then
  echo "${ROLE}" > /etc/saml-to/aws/role
  chmod +r /etc/saml-to/aws/role
fi

if [ -z "${REGION}" ]; then
  REGION="us-east-1"
fi
echo "${REGION}" > /etc/saml-to/aws/region
chmod +r /etc/saml-to/aws/region

if [ -z "${PROFILE}" ]; then
  PROFILE="default"
fi
echo "${PROFILE}" > /etc/saml-to/aws/profile
chmod +r /etc/saml-to/aws/profile
