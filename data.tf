# data.tf
###############

# aws_partition provides details of the current AWS partition of the terraform provider
data "aws_partition" "current" {}

# aws_region provides details about a specific AWS Region
data "aws_region" "current" {}

# aws_caller_identity provides access to the effective Account ID, User ID, and ARN in which Terraform is authorized
data "aws_caller_identity" "current" {}


data "external" "does_config_delivery_s3_bucket_exist" {
  program = ["bash", "-c", <<EOT
    set -e
    if aws s3api head-bucket --bucket "$BUCKET" 2>/dev/null; then
      echo "{\"exists\": true}"
    else
      echo "{\"exists\": false}"
    fi
  EOT
  ]

  query = {
    BUCKET = local.config_delivery_bucket_name
  }
}