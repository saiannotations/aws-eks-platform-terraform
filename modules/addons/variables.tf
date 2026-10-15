variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "addons" {
  description = "Map of EKS add-ons to manage."
  type = map(object({
    version                  = string
    service_account_role_arn = optional(string)
  }))
  default = {
    "vpc-cni" = {
      version = "v1.18.1-eksbuild.1"
    }
    "coredns" = {
      version = "v1.11.1-eksbuild.4"
    }
    "kube-proxy" = {
      version = "v1.30.0-eksbuild.3"
    }
  }
}

variable "tags" {
  description = "Extra tags applied to all resources."
  type        = map(string)
  default     = {}
}
