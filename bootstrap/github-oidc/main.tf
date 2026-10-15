# ---------------------------------------------------------------------------
# GitHub OIDC bootstrap: lets GitHub Actions authenticate to AWS with
# short-lived tokens. Apply this ONCE per account, before the workflows run.
# No static AWS keys are stored in GitHub secrets — ever.
# ---------------------------------------------------------------------------

data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github.certificates[0].sha1_fingerprint]

  tags = var.tags
}

resource "aws_iam_role" "github_ci" {
  name = "${var.project}-github-ci"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.github.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          # Only this repo, any branch or tag. Tighten to refs/heads/main
          # for the apply role in a stricter setup.
          "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}/${var.github_repo}:*"
        }
      }
    }]
  })

  tags = var.tags
}

# Broad enough for Terraform to manage the platform; scope this down per
# environment (separate plan/apply roles) once the platform stabilizes.
resource "aws_iam_role_policy_attachment" "github_ci_poweruser" {
  role       = aws_iam_role.github_ci.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

output "ci_role_arn" {
  description = "Role ARN the GitHub workflows assume. Store as a repo variable, not a secret."
  value       = aws_iam_role.github_ci.arn
}
