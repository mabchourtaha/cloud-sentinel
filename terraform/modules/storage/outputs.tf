output "bucket_name" {
  value = aws_s3_bucket.app_bucket.id
}

output "bucket_arn" {
  description = "Used by the IAM module to scope the policy"
  value       = aws_s3_bucket.app_bucket.arn
}
