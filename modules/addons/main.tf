# ---------------------------------------------------------------------------
# EKS add-ons managed as code: instead of letting EKS silently install
# default versions, every add-on version is pinned here and upgraded
# through pull requests like any other change.
# ---------------------------------------------------------------------------

resource "aws_eks_addon" "this" {
  for_each = var.addons

  cluster_name             = var.cluster_name
  addon_name               = each.key
  addon_version            = each.value.version
  service_account_role_arn = each.value.service_account_role_arn

  # On first install, overwrite any defaults EKS may have placed.
  resolve_conflicts_on_create = "OVERWRITE"
  # On later updates, never surprise-upgrade a running add-on.
  resolve_conflicts_on_update = "PRESERVE"

  tags = var.tags
}
