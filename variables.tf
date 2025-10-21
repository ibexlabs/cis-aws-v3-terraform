# variables.tf
###############

# Variable aws_region is the region where AWS Security Hub will be enabled 
variable "aws_region" {
  type = string
  #   default = "us-east-1"
  description = "AWS region of the Primary AWS Region on your Production AWS account"
}

variable "ibexlabs_cross_account_role_name" {
  type        = string
  default     = "ibexlabs-crossaccount"
  description = "Name of the Ibexlabs cross-account role"
}
