variable "allowed_methods" {
  type        = list(string)
}

variable "cached_methods" {
  type        = list(string)
}

variable "compress" {
  type        = bool
}

variable "default_ttl" {
  type        = number
}

variable "target_origin_id" {
  type        = string
}

variable "enabled" {
  type        = bool
}

variable "is_ipv6_enabled" {
  type        = bool
}

variable "origin_domain_name" {
  type        = string
}

variable "origin_id" {
  type        = string
}