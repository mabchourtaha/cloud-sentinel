resource "aws_s3_bucket" "app_bucket" {
  bucket        = "${var.project_name}-app-${var.bucket_suffix}"
  force_destroy = true

  tags = {
    Name    = "${var.project_name}-app-bucket"
    Project = var.project_name
  }
}

#
# Keeps old versions so an accidental overwrite/delete isn't permanent.
#

resource "aws_s3_bucket_versioning" "app_bucket" {
  bucket = aws_s3_bucket.app_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

#
# Encrypted at rest by default, even if the app forgets to ask for it
#

resource "aws_s3_bucket_server_side_encryption_configuration" "app_bucket" {
  bucket = aws_s3_bucket.app_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

#
# Block Public Access, all 4 settings on. This is the actual lock
# even a bad bucket policy or a public ACL added later can't expose
# this bucket. Same control that would've prevented the classic
# "accidentally public S3 bucket" misconfiguration.
#

resource "aws_s3_bucket_public_access_block" "app_bucket" {
  bucket = aws_s3_bucket.app_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
