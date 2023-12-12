# Frequently Asked Questions

Have a question? Please [Create an Issue](https://github.com/saml-to/devcontainer-features/issues) or [Start a Discussion](https://github.com/saml-to/devcontainer-features/discussions).

## Can Roles be Assumed be used in GitHub Actions?

Yes! Use our [assume-aws-role-action](https://github.com/saml-to/assume-aws-role-action).

## Can Roles be Assumed outside of Codespaces?

Yes! Use our [GitHub App](https://github.com/apps/saml-to) in conjunction with our [CLI](https://github.com/saml-to/cli).

## I get an error that "Multiple Roles Match" a given Role...

Find your organization's `saml-to.yml`. You'll likely find that the same Role ARN is defined twice:

```yaml
# ...snip...
permissions:
  aws:
    roles:
      - name: arn:aws:iam::123456789012:role/some-role
        users:
          github:
            - some-user
  another-aws: # the desired provider
    roles:
      - name: arn:aws:iam::123456789012:role/some-role
        users:
          github:
            - another-user
```

Update your `devcontainer.json` to explicitly specify which provider to use:

### Usage in `devcontainer.json`

```json
"features": {
    "ghcr.io/saml-to/devcontainer-features/assume-aws-role:2": {
        "role": "arn:aws:iam::123456789012:role/some-role",
        "provider": "another-aws" // matches "the desired provider"
    }
}
```
