
# DEMO ONLY — never applied. Reproduces the exact misconfiguration
# simulated manually in this incident scenario to show what Checkov
# would have caught if this had gone through Terraform instead.

resource "aws_s3_bucket_public_access_block" "test" {
  bucket                  = "test-bucket"
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}