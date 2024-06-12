variable "cluster_identifier" {
  type        = string
  description = "The identifier for the DocumentDB cluster."
}

variable "engine" {
  type        = string
  description = "The name of the database engine to be used for the cluster."
}

variable "master_username" {
  type        = string
  description = "The username for the master user."
}

variable "master_password" {
  type        = string
  description = "The password for the master user."
}

variable "apply_immediately" {
  type        = bool
  description = "Specifies whether any cluster modifications are applied immediately, or during the next maintenance window."
}

variable "skip_final_snapshot" {
  type        = bool
  description = "Specifies whether a final DB snapshot is created before the cluster is deleted."
}

variable "db_subnet_group_name" {
  type        = string
  description = "The name of the DB subnet group to associate with the cluster."
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = "The IDs of the VPC security groups to associate with the cluster."
}

variable "instance_count" {
  type        = number
  description = "The number of instances to create for the cluster."
}

variable "instance_identifier" {
  type        = list(string)
  description = "The identifiers for the instances to create for the cluster."
}

variable "instance_class" {
  type        = string
  description = "The instance class to use for the instances."
}

variable "tags" {
  type        = map(string)
  description = "The tags to apply to the cluster and instances."
}