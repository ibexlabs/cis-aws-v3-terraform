# outputs.tf
###############

# Outputs the ID of the AWS Security Hub
output "is_securityhub_enabled" {
  value       = aws_securityhub_account.securityhub_account.id
  description = "Is AWS Security Hub enabled in the AWS account and region specified?"
}

# Outputs the ARN of the CIS v3 Standard that is subscribed
output "cis_standards_arn" {
  value       = aws_securityhub_standards_subscription.cis_v3.standards_arn
  description = "ARN of the CIS v3 Standard that is subscribed"
}

# Outputs the name of the AWS Config Delivery S3 Bucket
output "config_delivery_bucket" {
  value       = aws_s3_bucket.config_delivery_bucket.bucket
  description = "Name of the AWS Config Delivery S3 Bucket"
}

# Outputs the ARN of the AWS Config Recorder role
output "config_recorder_role" {
  value       = aws_iam_role.config_recorder_role.arn
  description = "ARN of the AWS Config Recorder role"
}