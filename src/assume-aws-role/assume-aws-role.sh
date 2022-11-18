#!/usr/bin/env bash

set -e

GITHUB_TOKEN=$(cat /workspaces/.codespaces/shared/.env | grep GITHUB_TOKEN | sed "s/GITHUB_TOKEN=//1")

if [ -z "${GITHUB_TOKEN}" ]; then
    echo "Error: GITHUB_TOKEN is not set" >&2
    exit 1
fi

ROLE="$(cat /etc/saml-to/aws/role)"

if [ -z "${ROLE}" ]; then
    echo "Error: /etc/saml-to/aws/role is missing" >&2
    exit 1
fi

REGION="$(cat /etc/saml-to/aws/region)"

if [ -z "${REGION}" ]; then
    echo "Error: /etc/saml-to/aws/region is not set" >&2
    exit 1
fi

echo "[$(date)] Assuming Credentials for Role: ${ROLE}"

ROLE_ENCODED=$(echo "${ROLE}" | jq -Rr @uri)

assumeResponse=$(curl -X POST -H "accept: application/json" -A "devcontaier-features/assume-aws-role" -H "Authorization: Bearer ${GITHUB_TOKEN}" "https://sso.saml.to/github/api/v1/idp/roles/${ROLE_ENCODED}/assume" 2>/dev/null)

message=$(echo "${assumeResponse}" | jq -r .message)

if [ ! -z "${message}" ]; then
    echo "--> Error: ${message}" >&2
    exit 1
fi

samlRequest=$(echo "${assumeResponse}" | jq -r .samlHttpRequest)

content_type=$(echo "${samlRequest}" | jq -r .contentType)
url=$(echo "${samlRequest}" | jq -r .url)
method=$(echo "${samlRequest}" | jq -r .method)
payload=$(echo "${samlRequest}" | jq -r .payload)

samlResponse=$(curl -X "${method}" -H "Accept: application/json" -H "Content-Type: ${content_type}" --data "${payload}" "${url}" 2>/dev/null )

accessKeyId=$(echo "${samlResponse}" | jq -r .AssumeRoleWithSAMLResponse.AssumeRoleWithSAMLResult.Credentials.AccessKeyId)
secretAccessKey=$(echo "${samlResponse}" | jq -r .AssumeRoleWithSAMLResponse.AssumeRoleWithSAMLResult.Credentials.SecretAccessKey)
sessionToken=$(echo "${samlResponse}" | jq -r .AssumeRoleWithSAMLResponse.AssumeRoleWithSAMLResult.Credentials.SessionToken)

AWS_DIR="${HOME}/.aws"
AWS_CREDENTIALS_FILE="${AWS_DIR}/credentials"
AWS_CONFIG_FILE="${AWS_DIR}/config"

mkdir -p "${AWS_DIR}"

echo "[default]" > "${AWS_CREDENTIALS_FILE}"
echo "aws_access_key_id = ${accessKeyId}" >> "${AWS_CREDENTIALS_FILE}"
echo "aws_secret_access_key = ${secretAccessKey}" >> "${AWS_CREDENTIALS_FILE}"
echo "aws_session_token = ${sessionToken}" >> "${AWS_CREDENTIALS_FILE}"
echo "--> AWS Credentials saved to to: ${AWS_CREDENTIALS_FILE}"

echo "[default]" > "${AWS_CONFIG_FILE}"
echo "region = ${REGION}" >> "${AWS_CONFIG_FILE}"
echo "--> AWS Config saved to to: ${AWS_CONFIG_FILE}"

echo "--> Successfully Refreshed Credentials for Role: ${ROLE}"
