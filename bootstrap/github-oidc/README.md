# GitHub OIDC bootstrap

Run this once per AWS account, before the CI workflows:

```bash
cd bootstrap/github-oidc
terraform init
terraform apply
```

Copy the `ci_role_arn` output into a GitHub **repository variable** (not a
secret — an ARN is not sensitive) named `AWS_CI_ROLE_ARN`. The workflows in
`.github/workflows/` assume this role with short-lived OIDC tokens, so there
are no static AWS access keys anywhere in CI.
