variable "project" {
  description = "Project name used to prefix backend resource names."
  type        = string
  default     = "eks-platform"
}

variable "aws_region" {
  description = "AWS region for the state backend resources."
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Tags applied to the backend resources."
  type        = map(string)
  default     = {}
}
