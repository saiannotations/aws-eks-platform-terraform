variable "project" {
  description = "Project name."
  type        = string
  default     = "eks-platform"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "staging"
}

variable "aws_region" {
  description = "AWS region."
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "EKS cluster name."
  type        = string
  default     = "eks-platform-staging"
}

variable "cluster_version" {
  description = "Kubernetes version."
  type        = string
  default     = "1.30"
}

variable "vpc_cidr" {
  description = "VPC CIDR block."
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Availability zones."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs."
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}

variable "node_groups" {
  description = "Managed node group definitions."
  type = map(object({
    instance_types = list(string)
    capacity_type  = string
    min_size       = number
    max_size       = number
    desired_size   = number
    disk_size      = optional(number, 50)
    labels         = optional(map(string), {})
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), [])
  }))
  default = {
    general = {
      instance_types = ["t3.large"]
      capacity_type  = "ON_DEMAND"
      min_size       = 2
      max_size       = 5
      desired_size   = 3
    }
    spot = {
      instance_types = ["t3.large", "t3a.large"]
      capacity_type  = "SPOT"
      min_size       = 0
      max_size       = 6
      desired_size   = 2
      labels         = { workload = "batch" }
      taints         = [{ key = "spot", value = "true", effect = "NoSchedule" }]
    }
  }
}
