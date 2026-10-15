output "addon_names" {
  description = "Names of the managed EKS add-ons."
  value       = keys(aws_eks_addon.this)
}
