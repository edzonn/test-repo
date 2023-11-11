variable "name" {
  type        = string
  description = "The name of the security group."
}

variable "description" {
  type        = string
  description = "The description of the security group."
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC where the security group should be created."
}

variable "from_port" {
  type        = number
  description = "The starting port number for the ingress rule."
}

variable "to_port" {
  type        = number
  description = "The ending port number for the ingress rule."
}

variable "protocol" {
  type        = string
  description = "The protocol for the ingress rule."
}

variable "security_groups" {
  type        = list(string)
  description = "The security groups to allow access from."
}

variable "egress_from_port" {
  type        = number
  description = "The starting port number for the egress rule."
}

variable "egress_to_port" {
  type        = number
  description = "The ending port number for the egress rule."
}

variable "egress_protocol" {
  type        = string
  description = "The protocol for the egress rule."
}

variable "egress_cidr_blocks" {
  type        = list(string)
  description = "The CIDR blocks to allow access to for egress traffic."
}

variable "tags" {
  type        = map(string)
  description = "The tags to apply to the security group."
}