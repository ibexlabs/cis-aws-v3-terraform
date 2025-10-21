# provider.tf
###############

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.8.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.3"
    }
    external = {
      source  = "hashicorp/external"
      version = "2.3.5"
    }
  }
  required_version = "~> 1.12.2"
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Owner      = "Ibexlabs"
      Email      = "onboarding@ibexlabs.com"
      AWSPartner = "Ibexlabs"
      Product    = "Ibexlabs WAFR/FTR Assessment"
    }
  }
  alias = "primary"
}





