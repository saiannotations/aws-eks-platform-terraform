# Remote state. Create the backend first (see ../../backend), then replace
# 123456789012 with your AWS account ID — or pass -backend-config on init.
terraform {
  backend "s3" {
    bucket         = "eks-platform-tfstate-123456789012"
    key            = "envs/prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "eks-platform-tflocks"
    encrypt        = true
  }
}
