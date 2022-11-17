
# Assume AWS Role (assume-aws-role)

Assume an AWS role using SAML.to

## Example Usage

```json
"features": {
    "ghcr.io/saml-to/devcontainer-features/assume-aws-role:0": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| role | [REQUIRED] The AWS Role Name (or ARN) | string | undefined |
| region | (Optional) The AWS region ($AWS_DEFAULT_REGION) to set | string | us-east-1 |

TODO Notes!


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/saml-to/devcontainer-features/blob/main/src/assume-aws-role/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
