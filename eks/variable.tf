variable "aws_region" {
  default = "ap-southeast-1"
}

variable "scaling_policies" {
  type = map(object({
    name                      = string
    scaling_adjustment        = number
    cooldown                  = number
    estimated_instance_warmup = number
  }))
  default = {
    cpu_scaling = {
      name                      = "cpu-scaling-policy"
      scaling_adjustment        = 1
      cooldown                  = 300
      estimated_instance_warmup = 180
    }
    memory_scaling = {
      name                      = "memory-scaling-policy"
      scaling_adjustment        = 2
      cooldown                  = 600
      estimated_instance_warmup = 240
    }
  }
}