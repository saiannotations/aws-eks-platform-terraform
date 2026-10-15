variable "project" {
  description = "Project name used to prefix resource names."
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)."
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster these node groups join."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for the worker nodes."
  type        = list(string)
}

variable "node_groups" {
  description = "Map of managed node group definitions."
  type = map(object({
    instance_types = list(string)
    capacity_type  = string # ON_DEMAND or SPOT
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
}

variable "tags" {
  description = "Extra tags applied to all resources."
  type        = map(string)
  default     = {}
}
