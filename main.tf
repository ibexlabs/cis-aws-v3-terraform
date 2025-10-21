# main.tf
###############

###############
# AWS Security Hub CSPM 
###############

# Enables AWS Security Hub on this account
resource "aws_securityhub_account" "securityhub_account" {
  # Enables Security Hub in this account/region
  region                   = var.aws_region
  enable_default_standards = false
  auto_enable_controls     = true
  #   depends_on = []
}

# Enables the CIS AWS Foundations Benchmark v3 Standard within AWS Security Hub
resource "aws_securityhub_standards_subscription" "cis_v3" {
  # Subscribes only to the CIS AWS Foundations Benchmark v3 Standard
  standards_arn = local.cis_v3_standards_susbcription_arn
  # Ensures Security Hub account resource is created first
  depends_on = [aws_securityhub_account.securityhub_account]
}

###############
# AWS Config
###############

# Creates an Amazon S3 bucket to store AWS Config data
resource "aws_s3_bucket" "config_delivery_bucket" {
  count  = data.external.does_config_delivery_s3_bucket_exist.result.exists ? 0 : 1
  bucket = local.effective_config_delivery_bucket_name
}

# Creates an ACL on the AWS Config Delivery Bucket
resource "aws_s3_bucket_acl" "config_delivery_bucket_acl" {
  bucket = aws_s3_bucket.config_delivery_bucket.id
  acl    = "private"
}

# Enables versioning on the AWS Config Delivery Bucket
resource "aws_s3_bucket_versioning" "config_delivery_bucket_versioning" {
  bucket = aws_s3_bucket.config_delivery_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enables Server-side Encryption (SSE) on the AWS Config Delivery Bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "config_delivery_bucket_sse_configuration" {
  bucket = aws_s3_bucket.config_delivery_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

# Set up an Amazon S3 bucket lifecycle policy
resource "aws_s3_bucket_lifecycle_configuration" "config_delivery_bucket_lifecycle_configuration" {
  bucket = aws_s3_bucket.config_delivery_bucket.id

  rule {
    id     = "expire-logs"
    status = Enabled
    expiration {
      days = 365
    }
  }
}

# Creates the IAM role for the AWS Config Configuration Recorder
resource "aws_iam_role" "config_recorder_role" {
  name = "aws-config-recorder-role-${data.aws_caller_identity.current.account_id}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "config.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# Creates an AWS Config Configuration Recorder IAM Policy 
resource "aws_iam_role_policy" "config_recorder_policy" {
  name = "aws-config-recorder-policy-${data.aws_caller_identity.current.account_id}"
  role = aws_iam_role.config_recorder_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetBucketAcl",
          "s3:GetBucketLocation"
        ]
        Resource = [
          aws_s3_bucket.config_delivery_bucket.arn,
          "${aws_s3_bucket.config_delivery_bucket.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:GenerateDataKey",
          "kms:Encrypt",
          "kms:Decrypt"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "config:*"
        ]
        Resource = "*"
      }
    ]
  })
}

# Creates an AWS Config Configuration Recorder
resource "aws_config_configuration_recorder" "config_configuration_recorder" {
  name     = "aws_config_ftr"
  role_arn = aws_iam_role.config_recorder_role.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

# Creates the AWS Config Delivery Channel
resource "aws_config_delivery_channel" "config_delivery_channel" {
  name           = "aws_config_ftr_delivery_channel"
  s3_bucket_name = aws_s3_bucket.config_delivery_bucket.bucket
  depends_on     = [aws_config_configuration_recorder.config_configuration_recorder]
}

# Starts the AWS Config Configuration Recorder
resource "aws_config_configuration_recorder_status" "config_configuration_recorder_status" {
  name       = aws_config_configuration_recorder.config_configuration_recorder.name
  is_enabled = true

  depends_on = [
    aws_config_delivery_channel.config_delivery_channel,
  ]
}