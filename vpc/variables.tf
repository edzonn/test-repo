variable "public_subnet_cidr" {
  description = "The CIDR block for the public subnet"
  default     = ["10.143.48.0/24", "10.143.49.0/24", "10.143.50.0/24"]
  type        = list(any)
}

variable "private_subnet_cidr" {
  description = "The CIDR block for the private subnet"
  default     = ["10.143.0.0/24", "10.143.16.0/24", "10.143.32.0/24"]
  type        = list(any)
}

variable "private_db_subnet_cidr" {
  description = "The CIDR block for the private subnet"
  default     = ["10.143.51.0/24", "10.143.52.0/24", "10.143.53.0/24"]
  type        = list(any)
}

variable "availability_zones" {
  description = "The AZ for the private subnet"
  default     = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
  type        = list(any)
}

variable "region" {
  description = "The region for the VPC"
  default     = "ap-southeast-1"
  type        = string
}

