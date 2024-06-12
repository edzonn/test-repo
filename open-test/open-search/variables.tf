variable "vpc" { 
  type = string 
}

variable "hosted_zone_name" { 
  type = string 
}

variable "security_options_enabled" { 
  type = bool 
}

variable "volume_type" {
  type = string
}

variable "volume_size_auto_resize" {
  type = bool
}
 
variable "throughput" {
  type = number
}

variable "ebs_enabled" {
  type = bool
}

variable "ebs_volume_size" {
  type = number
}

variable "service" { 
  type = string 
}

variable "instance_type" { 
  type = string 
}

variable "instance_count" { 
  type = number 
}

variable "dedicated_master_enabled" {
  type    = bool
  default = false
}

variable "dedicated_master_count" {
  type    = number
  default = 0
}

variable "dedicated_master_type" {
  type    = string
  default = null
}

variable "zone_awareness_enabled" {
  type    = bool
  default = false
}

variable "engine_version" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "master_user_name"{
  type = string
  # default = "root"
}    
      
variable "master_user_password" {
  type = string
  # default = "P4ssw0rd123@"
}

variable "access_policy" {
  type        = string
  default     = null
}

variable "default_policy_for_fine_grained_access_control" {
  type        = bool
  default     = false
}


variable "access_policies" {
  type    = string
  default = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "es:*",
      "arn:aws:es:ap-southeast-1:092744370500:domain/da-mlops-opensearch-engine/*"
    }
  ]
}
EOF
}