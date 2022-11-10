#!/bin/sh
set -e

if [ -z "${GITHUB_TOKEN}" ]; then
    echo "Error: \$GITHUB_TOKEN is not set" >&2
    exit 1
fi

if [ -z "$1" ]; then
    echo "Usage: assume.sh [role]" >&2
    exit 1
fi

ROLE="$1"

samlRequest=$(curl -X POST -H "accept: application/json" -H "Authorization: Bearer ${GITHUB_TOKEN}" "https://sso.saml.to/github/api/v1/idp/roles/${ROLE}/assume" 2>/dev/null | jq -r .samlHttpRequest)

# echo "saml request: ${samlRequest}"

content_type=$(echo "${samlRequest}" | jq -r .contentType)
url=$(echo "${samlRequest}" | jq -r .url)
method=$(echo "${samlRequest}" | jq -r .method)
payload=$(echo "${samlRequest}" | jq -r .payload)

samlResponse=$(curl -X "${method}" -H "Accept: application/json" -H "Content-Type: ${content_type}" --data "${payload}" "${url}" 2>/dev/null )

accessKeyId=$(echo "${samlResponse}" | jq -r .AssumeRoleWithSAMLResponse.AssumeRoleWithSAMLResult.Credentials.AccessKeyId)
secretAccessKey=$(echo "${samlResponse}" | jq -r .AssumeRoleWithSAMLResponse.AssumeRoleWithSAMLResult.Credentials.SecretAccessKey)
sessionToken=$(echo "${samlResponse}" | jq -r .AssumeRoleWithSAMLResponse.AssumeRoleWithSAMLResult.Credentials.SessionToken)

mkdir -p ${HOME}/.aws

echo "[default]" > ${HOME}/.aws/credentials
echo "aws_access_key_id = ${accessKeyId}" >> ${HOME}/.aws/credentials
echo "aws_secret_access_key = ${secretAccessKey}" >> ${HOME}/.aws/credentials
echo "aws_session_token = ${sessionToken}" >> ${HOME}/.aws/credentials

echo "[default]" > ${HOME}/.aws/config
echo "region = us-east-1" >> ${HOME}/.aws/config

echo "Refreshed Credentials for Role: ${ROLE}"
