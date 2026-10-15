variable "project" {
  description = "Project name."
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)."
  type        = string
}

variable "owner" {
  description = "Team or person responsible for the resources."
  type        = string
  default     = "platform-team"
}

variable "cost_center" {
  description = "Cost center code for AWS Cost Explorer allocation."
  type        = string
  default     = "engineering"
}

variable "extra_tags" {
  description = "Additional tags merged on top of the standard set."
  type        = map(string)
  default     = {}
}
