terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  
  # Local state for this MVP — remote backend (S3 + DynamoDB lock)
  # is a documented future improvement, not done here on purpose.
  
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}


module "networking" {
  source = "./modules/networking"

  project_name = var.project_name
}


module "storage" {
  source = "./modules/storage"

  project_name  = var.project_name
  bucket_suffix = var.bucket_suffix
}


module "iam" {
  source = "./modules/iam"

  project_name  = var.project_name
  s3_bucket_arn = module.storage.bucket_arn
}


module "compute" {
  source = "./modules/compute"

  project_name          = var.project_name
  vpc_id                = module.networking.vpc_id
  subnet_id             = module.networking.public_subnet_id
  instance_profile_name = module.iam.instance_profile_name
  ssh_allowed_cidr      = var.ssh_allowed_cidr
  key_name = "cloud-sentinel-key"

}


resource "aws_cloudwatch_log_group" "app_logs" {
  name              = "/cloud-sentinel/${var.project_name}/app"
  retention_in_days = 30

  tags = {
    Project = var.project_name
  }
}


# 80% for 10 min — real signal without false positives on a short spike


resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.project_name}-ec2-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "App instance CPU above 80% for 10 minutes"

  dimensions = {
    InstanceId = module.compute.instance_id
  }

  tags = {
    Project = var.project_name
  }
}


# Lets CloudTrail write logs into the app bucket under "cloudtrail/" —
# one bucket, two purposes, to keep this MVP's scope tight


data "aws_iam_policy_document" "cloudtrail_bucket_policy" {
  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:GetBucketAcl"]
    resources = [module.storage.bucket_arn]
  }

  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:PutObject"]
    resources = ["${module.storage.bucket_arn}/cloudtrail/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}

resource "aws_s3_bucket_policy" "cloudtrail" {
  bucket = module.storage.bucket_name
  policy = data.aws_iam_policy_document.cloudtrail_bucket_policy.json
}


# Audit trail of every AWS API call on this account — the "who did what,
# when" record you'd need to investigate an incident

resource "aws_cloudtrail" "main" {
  name                          = "${var.project_name}-trail"
  s3_bucket_name                = module.storage.bucket_name
  s3_key_prefix                 = "cloudtrail"
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true

  depends_on = [aws_s3_bucket_policy.cloudtrail]

  tags = {
    Project = var.project_name
  }
}
