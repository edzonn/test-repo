variable "ami" {
  description = "The ID of the AMI to use for the EC2 instance"
}

variable "instance_type" {
  description = "The type of EC2 instance to launch"
}

variable "key_name" {
  description = "The name of the key pair to use for SSH access"
}

variable "subnet_id" {
  description = "The ID of the subnet to launch the EC2 instance in"
}

variable "vpc_security_group_ids" {
  description = "A list of security group IDs to associate with the EC2 instance"
}

variable "root_volume_size" {
  description = "The size of the root volume in GB"
#   default     = 70
    
}

variable "root_volume_type" {
  description = "The type of the root volume"
#   default     = "gp3"
    default = ""
}

variable "root_volume_iops" {
  description = "The number of IOPS to provision for the root volume"
#   default     = 3000
    default = ""
}

variable "root_volume_throughput" {
  description = "The throughput to provision for the root volume in MB/s"
#   default     = 125
    default = ""
}

variable "root_volume_encrypted" {
  description = "Whether to encrypt the root volume"
  default     = true
}

variable "root_volume_kms_key_id" {
  description = "The ARN of the KMS key to use for root volume encryption"
}

variable "ebs_block_devices" {
  description = "A list of EBS block devices to attach to the EC2 instance"
  default     = []
}

variable "user_data" {
  description = "The user data to use when launching the EC2 instance"
  default     = ""
}