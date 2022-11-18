# Frequently Asked Questions

Have a question? Please [Create an Issue](https://github.com/saml-to/devcontainer-features/issues) or [Start a Discussion](https://github.com/saml-to/devcontainer-features/discussions).

## Can Roles be Assumed be used in GitHub Actions?

Yes! Use our [assume-aws-role-action](https://github.com/saml-to/assume-aws-role-action).

## Can Roles be Assumed outside of Codespaces?

Yes! Use our [GitHub App](https://github.com/apps/saml-to) in conjunction with our [CLI](https://github.com/saml-to/cli).

## I'm not getting a role. How do I troubleshoot?

Run the following command inside a Terminal within a running Codespaces:

```bash
/usr/local/bin/assume-aws-role
```

Any errors will be shown. Please [Contact Us](https://saml.to/contact) if you need assistance!
