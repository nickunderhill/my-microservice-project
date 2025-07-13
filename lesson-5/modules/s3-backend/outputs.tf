output "s3_bucket_name" {
  description = "S3-bucket URL"
  value       = aws_s3_bucket.terraform_state.bucket_regional_domain_name
}

output "dynamodb_table_name" {
  description = "Назва таблиці DynamoDB для блокування стейтів"
  value       = aws_dynamodb_table.terraform_locks.name
}
