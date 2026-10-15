output "cluster_name" {
  description = "Name of the EKS cluster."
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "Kubernetes API server endpoint."
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_ca_certificate" {
  description = "Base64-encoded cluster CA certificate."
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "oidc_provider_arn" {
  description = "ARN of the IAM OIDC provider, used to build IRSA roles."
  value       = aws_iam_openid_connect_provider.cluster.arn
}

output "oidc_issuer_url" {
  description = "OIDC issuer URL of the cluster."
  value       = aws_eks_cluster.this.identity[0].oidc[0].issuer
}
