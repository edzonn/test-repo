variable "aws_region" {
  description = "(Optional) This is the AWS region. It must be provided, but it can also be sourced from the AWS_DEFAULT_REGION environment variables, or via a shared credentials file if profile is specified."
  default = "us-east-1"
}

// aws_efs_file_system

variable "creation_token" {
  description = "(Optional) A unique name (a maximum of 64 characters are allowed) used as reference when creating the Elastic File System to ensure idempotent file system creation. By default generated by Terraform. See [Elastic File System] (http://docs.aws.amazon.com/efs/latest/ug/) user guide for more information."
}

variable "encrypted" { 
  default = true
}

variable "kms_key_id" { 
  default = null
}

variable "performance_mode" { 
  default = "generalPurpose"
}

variable "throughput_mode" { 
  default = "bursting"
}

variable "provisioned_throughput_in_mibps" { 
  default = null
}

variable "tags" {
  default = {}
}

variable "lifecycle_policy" {
  description = "(Optional) A file system lifecycle policy object (documented below)."
  default = "AFTER_30_DAYS"
}

// aws_efs_mount_target

variable "subnet_id" {
  description = "(Required) The ID of the subnet to add the mount target in."
  default = []
}
