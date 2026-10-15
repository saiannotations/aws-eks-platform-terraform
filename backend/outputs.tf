output "state_bucket" {
  description = "S3 bucket name to use in backend \"s3\" blocks."
  value       = aws_s3_bucket.tfstate.id
}

output "lock_table" {
  description = "DynamoDB table name to use as dynamodb_table in backend \"s3\" blocks."
  value       = aws_dynamodb_table.tflocks.name
}
