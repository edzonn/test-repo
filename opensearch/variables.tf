# create variables for aws opensearch terraform module


variable "name" {
  description = "The name of the domain."
  type        = string
}

variable "domain_name" {
  description = "The name of the domain."
  type        = string
}

variable "domain_version" {
  description = "The version of Elasticsearch to deploy."
  type        = string
}

variable "instance_type" {
  description = "Instance type of data nodes in the cluster."
  type        = string
}

variable "instance_count" {
  description = "Number of data nodes in the cluster."
  type        = number
}

variable "dedicated_master_enabled" {
  description = "Indicates whether dedicated master nodes are enabled for the cluster."
  type        = bool
}

