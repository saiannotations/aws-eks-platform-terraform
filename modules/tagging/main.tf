# ---------------------------------------------------------------------------
# Tagging standard: every resource gets the same four cost-allocation tags
# so finance can slice the AWS bill by project and environment in
# Cost Explorer. Environments pass module.tagging.tags into every module.
# ---------------------------------------------------------------------------

output "tags" {
  description = "Standard tag map for all resources in an environment."
  value = merge(
    {
      Project     = var.project
      Environment = var.environment
      Owner       = var.owner
      CostCenter  = var.cost_center
      ManagedBy   = "terraform"
    },
    var.extra_tags
  )
}
