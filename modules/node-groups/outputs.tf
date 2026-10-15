output "node_group_names" {
  description = "Names of the created managed node groups."
  value       = { for k, ng in aws_eks_node_group.this : k => ng.node_group_name }
}

output "node_role_arn" {
  description = "ARN of the shared worker node IAM role."
  value       = aws_iam_role.nodes.arn
}
