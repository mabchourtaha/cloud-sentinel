output "app_public_ip" {
  description = "Use this to test the API"
  value       = module.compute.public_ip
}

output "s3_bucket_name" {
  value = module.storage.bucket_name
}

output "vpc_id" {
  value = module.networking.vpc_id
}

output "cloudtrail_name" {
  value = aws_cloudtrail.main.name
}
