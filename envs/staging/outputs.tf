output "cluster_name" {
  description = "EKS cluster name (for kubeconfig)."
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Kubernetes API endpoint."
  value       = module.eks.cluster_endpoint
}

output "vpc_id" {
  description = "VPC ID."
  value       = module.vpc.vpc_id
}
