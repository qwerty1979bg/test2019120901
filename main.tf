provider "aws" {
  version    = "~> 2.0"
  region     = "us-east-1"
}

variable "aws_accounts" {}

resource "aws_s3_bucket" "log_bucket" {
  bucket = "test2019-12-09-01${uuidv5("url", "test2019-12-09-01")}"
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.log_bucket.id
  policy = data.aws_iam_policy_document.cloud_trail_policy.json
}

data "aws_iam_policy_document" "cloud_trail_policy" {
  statement {
    sid = "AWSCloudTrailAclCheck"
    actions = [
      "s3:GetBucketAcl",
    ]
    effect = "Allow"
    resources = [
      aws_s3_bucket.log_bucket.arn
    ]
    principals {
      identifiers = [
        "cloudtrail.amazonaws.com"
      ]
      type = "Service"
    }
  }

  statement {
    sid = "AWSCloudTrailWrite"
    actions = [
      "s3:PutObject",
    ]
    effect    = "Allow"
    resources = var.aws_accounts
    principals {
      identifiers = [
      "cloudtrail.amazonaws.com"]
      type = "Service"
    }

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values = [
      "bucket-owner-full-control"]
    }
  }
}
