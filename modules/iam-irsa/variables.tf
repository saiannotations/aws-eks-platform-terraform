variable "project" {
  description = "Project name used to prefix resource names."
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)."
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the cluster's IAM OIDC provider."
  type        = string
}

variable "oidc_issuer_url" {
  description = "OIDC issuer URL of the cluster (https://...)."
  type        = string
}

variable "roles" {
  description = "Map of IRSA role definitions."
  type = map(object({
    namespace           = string
    service_account     = string
    policy_arns         = list(string)
    description         = optional(string, "")
  }))
}

variable "tags" {
  description = "Extra tags applied to all resources."
  type        = map(string)
  default     = {}
}
