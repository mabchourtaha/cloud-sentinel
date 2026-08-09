#
# Trust policy: only EC2 can assume this role. This is what lets an
# instance pull temporary credentials via the Instance Metadata Service,
# no access keys in code or env vars, no manual rotation.
#

data "aws_iam_policy_document" "ec2_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "app_role" {
  name               = "${var.project_name}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_trust.json

  tags = {
    Project = var.project_name
  }
}

#
# Scoped to this bucket's ARN only, no DeleteObject — if this role
# is ever compromised, blast radius is one bucket, not the account
#

data "aws_iam_policy_document" "s3_access" {
  statement {
    sid    = "ListBucket"
    effect = "Allow"
    actions = [
      "s3:ListBucket"
    ]
    resources = [var.s3_bucket_arn]
  }

  statement {
    sid    = "ReadWriteObjects"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = ["${var.s3_bucket_arn}/*"]
  }
}

resource "aws_iam_policy" "s3_access" {
  name        = "${var.project_name}-s3-access-policy"
  description = "Least-privilege S3 access: list + get/put only"
  policy      = data.aws_iam_policy_document.s3_access.json
}

resource "aws_iam_role_policy_attachment" "s3_access" {
  role       = aws_iam_role.app_role.name
  policy_arn = aws_iam_policy.s3_access.arn
}

#
# Wrapper that lets the EC2 instance actually assume the role above
#

resource "aws_iam_instance_profile" "app_profile" {
  name = "${var.project_name}-ec2-instance-profile"
  role = aws_iam_role.app_role.name
}
