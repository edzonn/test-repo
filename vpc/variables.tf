variable "public_subnet_cidr" {
    description = "The CIDR block for the public subnet"
    default     = ["10.10.21.0/24", "10.10.223.22.0/24", "10.10.23.0/24"]
    type        = list(any)  
}

variable "private_subnet_cidr" {
    description = "The CIDR block for the private subnet"
    default     = ["10.10.41.0/24", "10.10.42.0/24", "10.10.43.0/24"]
    type        = list(any)
}

variable "private_db_subnet_cidr" {
    description = "The CIDR block for the private subnet"
    default     = ["10.10.51.0/24", "10.10.52.0/24", "10.10.53.0/24"]
    type        = list(any)
}
  
variable "availability_zones" {
    description = "The AZ for the private subnet"
    default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
    type        = list(any)
}
  
