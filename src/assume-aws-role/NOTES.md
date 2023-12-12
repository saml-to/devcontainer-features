## Overview

This Devcontainer Feature enables GitHub Codespaces to obtain AWS Access Credentials for a desired IAM Role using **AWS IAM SAML** and a **GitHub Actions Repository Token**.

Benefits:

- No need to copy/paste AWS Access Tokens into Codespaces Secrets
- No need to rotate AWS Access Tokens

This action uses [SAML.to](https://saml.to) and an [AWS IAM Identity Provider](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_saml.html) to exchange the [Codespace User's GitHub Token](https://docs.github.com/en/codespaces/codespaces-reference/security-in-github-codespaces#authentication) for AWS Access Credentials.

This feature will store and rotate AWS credentials for the Devcontainer in:

- `/home/codespace/.aws/credentials`
- `/home/codespace/.aws/config`

### Usage in `devcontainer.json`

```json
"features": {
    "ghcr.io/saml-to/devcontainer-features/assume-aws-role:2": {
        "role": "arn:aws:iam::123456789012:role/some-role"
    }
}
```

## Usage

1. Follow the [Installation](#installation) instructions
1. [Launch the Devcontainer](#step-2-add-the-feature-to-devcontainerjson) using GitHub Codespaces
1. The `assume-aws-role` feature will automatically create and update:
   - `/home/codespace/.aws/credentials`
   - `/home/codespace/.aws/config`
   - When:
     - When first connecting to a codespace
     - Before the credentials expire (every ~30 minutes)

#### With the AWS CLI

Within a Terminal of Codespaces, you can:

- `aws sts get-caller-identity`: Show which role is assumed
- `aws s3 cp ...`: For example, if the role is granted S3 Access
- `aws ec2 describe-instances`: For example, if the role is granted EC2 Access

#### Within an Application

If Codespaces launches an Application (Python, Node, etc.) the AWS SDK installed ([boto3](https://pypi.org/project/boto3/), [@aws-sdk](https://www.npmjs.com/package/aws-sdk), etc) is configured to read credentials from `~/.aws/credentials`.

In Python (or even a [Jupyter Notebook](https://github.com/github/codespaces-jupyter) codespace!), for example:

```bash
pip install boto3
```

```python
import boto3

sts = boto3.client('sts')
s3 = boto3.client('s3')

print(sts.get_caller_identity())
print(s3.list_buckets())
```

## Installation

### Step 1: Configure AWS

1. [Download Your Metadata](https://saml.to/metadata) from SAML.to
1. If you haven't already, create a new **SAML** [Identity Provider](https://console.aws.amazon.com/iamv2/home?#/identity_providers/create) in AWS IAM
   1. **Provider Name**: _saml.to_
   1. **Metadata Document**: _Upload the **IdP Metadata** from [SAML.to](https://saml.to/metadata)_
   1. Make note of the **`Provder ARN`** in the AWS console
1. [Create or Edit an IAM Role](https://console.aws.amazon.com/iamv2/home?#/roles). Set the [Trust Relationship](https://docs.aws.amazon.com/directoryservice/latest/admin-guide/edit_trust.html) on a the Role to contain the following statement:

   ```
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Effect": "Allow",
         "Principal": {
           "Federated": "PROVIDER_ARN"
         },
         "Action": "sts:AssumeRoleWithSAML",
         "Condition": {
           "StringEquals": {
             "SAML:aud": "https://signin.aws.amazon.com/saml"
           }
         }
       }
     ]
   }
   ```

   - Replace `PROVIDER_ARN` with the newly created ARN of the provider, e.g. `arn:aws:iam::123456789012:saml-provider/saml.to`
   - Make note of the **`Role ARN`** for this Role

1. Add a new file named _`saml-to.yml`_ to the Codespaces Repository:

   `your-codespaces-repository/saml-to.yml`:

   ```
   ---
   version: "20220101"
   providers:
     aws:
       entityId: https://signin.aws.amazon.com/saml
       acsUrl: https://signin.aws.amazon.com/saml
       attributes:
         https://aws.amazon.com/SAML/Attributes/RoleSessionName: "<#= repo.name #>"
         https://aws.amazon.com/SAML/Attributes/SessionDuration: "3600"
         https://aws.amazon.com/SAML/Attributes/Role: "<#= system.selectedRole #>,<#= provider.variables.providerArn #>"
   permissions:
     aws:
       roles:
         - name: ROLE_ARN # Change this
           provider:
             variables:
               providerArn: PROVIDER_ARN # Change this
           users:
             github:
               - YOUR_GITHUB_USERNAME # Change this
   ```

   - Replace `PROVIDER_ARN` with the ARN of the provider created above (e.g. `arn:aws:iam::123456689012:saml-provider/my-repository`)
   - Replace `ROLE_ARN` with the ARN of the IAM Role modified above. (e.g. `arn:aws:iam::123456689012:role/admin`)
   - Replace `YOUR_GITHUB_USERNAME` with your GitHub User ID (e.g. `octokat`)
     - _Optional_: List any additional Github User IDs that may need this Codespace and Role

1. **Commit and Push** the changes to `saml-to.yml` to the **Default Branch** of the Codespaces Repository.

### Step 2: Add the Feature to `devcontainer.json`

1. Modify [`.devcontainer.json`](https://code.visualstudio.com/docs/devcontainers/create-dev-container) to add a `feature` which will setup the AWS Role:

   `your-repository/.devcontainer/devcontainer.json` or `your-repository/.devcontainer.json`:

   ```
   {
     ... other devcontainer.json configuration ...

     "features": {
       "ghcr.io/saml-to/devcontainer-features/assume-aws-role:2": {
         "role": "ROLE_ARN"
       },
       "ghcr.io/devcontainers/features/aws-cli:1": {}
     }
   }
   ```

   - Replace `ROLE_ARN` with the ARN of the IAM Role modified above. (e.g. `arn:aws:iam::123456689012:role/admin`)
   - _Note_: If installing `aws` CLI is not desired, remove `"ghcr.io/devcontainers/features/aws-cli:1": {}`

1. Rebuild the Container or Restart the Codespace to enable the Feature

### Changing the Default Region

Add the `region` option to the `assume-aws-role` feature:

`your-repository/.devcontainer/devcontainer.json` or `your-repository/.devcontainer.json`:

```
{
  ... other devcontainer.json configuration ...

  "features": {
    "ghcr.io/saml-to/devcontainer-features/assume-aws-role:1": {
      "role": "ROLE_ARN",
      "region": "us-west-2"
    },
    "ghcr.io/devcontainers/features/aws-cli:1": {}
  }
}
```

## FAQs

See [FAQs](FAQS.md)

## Maintainers

- [Scaffoldly](https://github.com/scaffoldly)
- [cnuss](https://github.com/cnuss)

## Help & Support

- [Message us on Gitter](https://gitter.im/saml-to/devcontainer-features)
- [Support via Twitter](https://twitter.com/SamlToSupport)
- [Discussions](https://github.com/saml-to/devcontainer-features/discussions)
- [Issues](https://github.com/saml-to/devcontainer-features/issues)

![](https://sso.saml.to/github/px?devcontainer-aws-assume-role)
