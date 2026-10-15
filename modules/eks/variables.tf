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

variable "cluster_version" {
  description = "Kubernetes version for the EKS control plane."
  type        = string
  default     = "1.30"
}

variable "private_subnet_ids" {
  description = "Private subnet IDs where the control plane ENIs and nodes live."
  type        = list(string)
}

variable "endpoint_public_access" {
  description = "Allow public access to the Kubernetes API endpoint (dev convenience; disable in prod)."
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch Logs retention for control-plane logs."
  type        = number
  default     = 30
}

variable "tags" {
  description = "Extra tags applied to all resources."
  type        = map(string)
  default     = {}
}
