output "role_arns" {
  description = "ARNs of the created IRSA roles, keyed by role name."
  value       = { for k, r in aws_iam_role.irsa : k => r.arn }
}
