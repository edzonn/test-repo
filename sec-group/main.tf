module "sg_app_server" {
  source         = "/mnt/c/Users/user/Desktop/terraform/test-repo/modules/security_group"
  vpc_id         = data.terraform_remote_state.module_outputs.outputs.vpc_id
  sg_name        = "test-sg-app-server"
  sg_description = "test-sg-app-server"
  ingress_rules = [
    {
      description = "allow on 443"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["10.10.10.10/32"]
      security_groups = [data.aws_security_group.alb.id]
    }
  ]
  egress_rules = [
    {
      description = "allow on 443"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = null
      security_groups = null
    }
  ]

  tags_sg = var.tags_sg
}






