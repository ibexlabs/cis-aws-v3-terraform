# locals.tf
###############

locals {
  # AWS Security Hub Standards Subscription ARN for the CIS AWS Foundations Benchmark v3.0.0
  cis_v3_standards_susbcription_arn = "arn:${data.aws_partition.current.partition}:securityhub:${data.aws_region.current.aws_region}::standards/cis-aws-foundations-benchmark/v/3.0.0"
  # Compose the default AWS Config S3 Bucket name
  config_delivery_bucket_name = "config-bucket-${data.aws_caller_identity.current.account_id}"
  # Conditionally choose the AWS Config S3 Bucket name
  effective_config_delivery_bucket_name = try(
    aws_s3_bucket.config_delivery_bucket[0].bucket,
    local.config_delivery_bucket_name
  )
}
