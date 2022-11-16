#!/bin/sh
set -e

GITHUB_TOKEN=$(cat /workspaces/.codespaces/.env | grep GITHUB_TOKEN | sed "s/GITHUB_TOKEN=//1")

if [ -z "${GITHUB_TOKEN}" ]; then
    echo "Error: GITHUB_TOKEN is not set" >&2
    exit 1
fi

ROLE="$(cat /workspaces/.codespaces/.saml-to/aws-role)"

if [ -z "${ROLE}" ]; then
    echo "Error: aws-role is not set" >&2
    exit 1
fi

PROFILE="$(cat /workspaces/.codespaces/.saml-to/aws-profile)"

if [ -z "${PROFILE}" ]; then
    echo "Error: aws-profile is not set" >&2
    exit 1
fi

REGION="$(cat /workspaces/.codespaces/.saml-to/aws-region)"

if [ -z "${REGION}" ]; then
    echo "Error: aws-region is not set" >&2
    exit 1
fi

ROLE_ENCODED=$(echo "${ROLE}" | jq -Rr @uri)

samlRequest=$(curl -X POST -H "accept: application/json" -A "devcontaier-features/assume-aws-role" -H "Authorization: Bearer ${GITHUB_TOKEN}" "https://sso.saml.to/github/api/v1/idp/roles/${ROLE_ENCODED}/assume" 2>/dev/null | jq -r .samlHttpRequest)

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

echo "[${PROFILE}]" > "${AWS_CREDENTIALS_FILE}"
echo "aws_access_key_id = ${accessKeyId}" >> "${AWS_CREDENTIALS_FILE}"
echo "aws_secret_access_key = ${secretAccessKey}" >> "${AWS_CREDENTIALS_FILE}"
echo "aws_session_token = ${sessionToken}" >> "${AWS_CREDENTIALS_FILE}"

echo "[${PROFILE}]" > "${AWS_CONFIG_FILE}"
echo "region = ${REGION}" >> "${AWS_CONFIG_FILE}"

echo "Refreshed Credentials for Role: ${ROLE}"
