
variable "family" {
    default     = "docdb3.6"
    type        = string
} 

variable "name" {
    default     = "da-mlops-test-docdb-param"
    type        = string
}

# variable "parameter_group_name" {
#     default     = 
#     type        = string
# }

variable "cluster_parameters" {
  type = list(object({
    apply_method = string
    name         = string
    value        = string
  }))
  default     = []
  description = "List of DB parameters to apply"
}

variable "instance_class" {
    default     = "db.t3.medium"
    type        = string
}

variable "storage_encrypted" {
    default     = "true"
    type        = string
}

variable "storage_type" {
    default     = "standard"
    type        = string
}

variable "engine" {
    default     = "docdb"
    type        = string
}

variable "master_username" {
    default     = "docdbadmin"
    type        = string
    sensitive = true
}

variable "master_password" {
    default     = "docdbadmin"
    type        = string
    sensitive = true
}

variable "apply_immediately" {
    default     = "true"
    type        = string
}

variable "skip_final_snapshot" {
    default     = "true"
    type        = string
}

variable "db_subnet_group_name" {
    default     = ""
    type        = string
}

variable "vpc_security_group_ids" {
    default     = "cluster_identifier"
    type        = string
}

variable "cluster_parameter_group_name" {
    default     = ""
    type        = string
}

variable "tags" {
    default     = ""
    type        = string
}

variable "security_group_name" {
    default     = ""
    type        = string
}

variable "cluster_identifier" {
    default     = "da-mlops-test-docdb"
    type        = string
}

# variable "engine" {
#     default     = "docdb"
#     type        = string
# }

variable "identifier" {
    default     = "da-mlops-test-docdb-instance"
    type        = string
}

variable "identifier-2" {
    default     = "da-mlops-test-docdb-instance-2"
    type        = string
}

variable "engine_version" {
    default     = "3.6.0"
    type        = string
}