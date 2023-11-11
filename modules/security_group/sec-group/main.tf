module "security_group" {
  source = "./security-group"

  name        = "da-mlops-test-sg"
  description = "da-mlops-test-sg"
  vpc_id      = data.terraform_remote_state.module_outputs.outputs.vpc_id

  from_port        = 4545
  to_port          = 4545
  protocol         = "tcp"
  security_groups  = [aws_security_group.da-mlops-test-lb.id]

  egress_from_port = 0
  egress_to_port   = 0
  egress_protocol  = "-1"
  egress_cidr_blocks = ["0.0.0.0/0"]

  tags = {
    Name = "da-mlops-test-sg"
  }
}