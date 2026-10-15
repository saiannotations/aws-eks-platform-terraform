variable "project" {
  description = "Project name used to prefix resource names."
  type        = string
  default     = "eks-platform"
}

variable "github_org" {
  description = "GitHub org or username that owns the repo."
  type        = string
  default     = "saiannotations"
}

variable "github_repo" {
  description = "Repository allowed to assume the CI role."
  type        = string
  default     = "aws-eks-platform-terraform"
}

variable "tags" {
  description = "Extra tags applied to all resources."
  type        = map(string)
  default     = {}
}
