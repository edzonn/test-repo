variable "efs_name" {
  description = "The name of the EFS file system"
  type        = string
}

variable "subnet_ids" {
  description = "The IDs of the subnets in which to create the EFS mount targets"
  type        = list(string)
}

variable "security_group_id" {
  description = "The ID of the security group to associate with the EFS mount targets"
  type        = string
}

variable "kms_key_id" {
  description = "The ARN of the KMS key to use for encryption. If not specified, AWS uses the AWS managed key for EFS."
  type        = string
  default     = null
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}