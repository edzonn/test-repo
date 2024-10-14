provider "aws" {
  region = ap-northeast-1
}
data "aws_availability_zones" "available" {}

module "nlb" {
  source = "terraform-aws-modules/terraform-aws-alb"

  name = local.name

  load_balancer_type               = "network"
  vpc_id                           = data.terraform_remote_state.module_outputs.outputs.vpc_id
  dns_record_client_routing_policy = "availability_zone_affinity"

  subnet_mapping = [for i, eip in aws_eip.this :
    {
      allocation_id = eip.id
      subnet_id     = data.terraform_remote_state.module_outputs.outputs.private_subnet_ids
    }
  ]
  enable_deletion_protection = false
  enforce_security_group_inbound_rules_on_private_link_traffic = "off"
  security_group_ingress_rules = {
    all_tcp = {
      from_port   = 5000
      to_port     = 5000
      ip_protocol = "tcp"
      description = "TCP traffic"
      cidr_ipv4   = "10.41.0.0.0/16" # change to SRPH IP if connection issue occurs
    }
    all_udp = {
      from_port   = 5000
      to_port     = 5000
      ip_protocol = "udp"
      description = "UDP traffic"
      cidr_ipv4   = "10.41.0.0.0/16" # change to SRPH IP if connection issue occurs
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "tcp"
      cidr_ipv4   = data.terraform_remote_state.module_outputs.outputs.vpc_id
    }
  }

  listeners = {
    ex-one = {
      port     = 5000
      protocol = "TCP_UDP"
      forward = {
        target_group_key = "gpu-poc"
      }
    }
  }

  target_groups = {
    gpu-poc = {
      name_prefix            = "gpu-poc"
      protocol               = "TCP_UDP"
      port                   = 5000
      target_type            = "instance"
      target_id              = <change> -->> change to the instance_id of the EC2 instance of Abraham
      connection_termination = true
      preserve_client_ip     = true

      stickiness = {
        type = "source_ip"
      }
    }
  }
}