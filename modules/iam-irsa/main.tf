# ---------------------------------------------------------------------------
# IRSA (IAM Roles for Service Accounts): give a single Kubernetes service
# account its own IAM role, instead of handing broad permissions to every
# pod on a worker node. The trust policy only allows the exact
# system:serviceaccount:<namespace>:<name> identity to assume the role.
# ---------------------------------------------------------------------------

locals {
  # "https://oidc.eks.us-east-1.amazonaws.com/id/ABC" -> "oidc.eks.us-east-1.amazonaws.com/id/ABC"
  oidc_host = replace(var.oidc_issuer_url, "https://", "")

  common_tags = merge(var.tags, {
    Project     = var.project
    Environment = var.environment
  })
}

resource "aws_iam_role" "irsa" {
  for_each = var.roles

  name        = "${var.cluster_name}-${each.key}-irsa"
  description = each.value.description != "" ? each.value.description : "IRSA role for ${each.value.namespace}/${each.value.service_account}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = var.oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${local.oidc_host}:sub" = "system:serviceaccount:${each.value.namespace}:${each.value.service_account}"
          "${local.oidc_host}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "irsa" {
  for_each = {
    for pair in flatten([
      for role_name, role in var.roles : [
        for policy_arn in role.policy_arns : {
          key        = "${role_name}-${md5(policy_arn)}"
          role_name  = role_name
          policy_arn = policy_arn
        }
      ]
    ]) : pair.key => pair
  }

  role       = aws_iam_role.irsa[each.value.role_name].name
  policy_arn = each.value.policy_arn
}
