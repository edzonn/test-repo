# create ec2 instane main.terraform {
provider "aws" {
  region = "ap-southeast-1"
}

data "terraform_remote_state" "module_outputs" {
  backend = "s3"
  config = {
    bucket = "aws-terraform-tfstatefile-001"
    key    = "dev/terraform.statefile"
    region = "ap-southeast-1"
  }
}

data "aws_kms_key" "default" {
  key_id = "alias/aws/ebs"
}

output "default_kms_arn" {
  value = data.aws_kms_key.default.arn
}

# create target_group

resource "aws_lb_target_group" "da-mlops-test-tg" {
  name     = "da-mlops-test-tg"
  port     = 4545
  protocol = "TCP"
  vpc_id   = data.terraform_remote_state.module_outputs.outputs.vpc_id
  tags = {
    Name = "da-mlops-test-tg"
  }
}

# create load balancer

resource "aws_security_group" "da-mlops-test-lb" {
  name        = "da-mlops-test-lb"
  description = "da-mlops-test-lb"
  vpc_id      = data.terraform_remote_state.module_outputs.outputs.vpc_id
  ingress {
    from_port   = 4545
    to_port     = 4545
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 4545
    to_port     = 4545
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  tags = {
    Name = "da-mlops-test-lb"
  }
}

resource "aws_lb" "da-mlops-test-lb" {
  name               = "da-mlops-test-lb"
  internal           = false
  load_balancer_type = "network"
  security_groups    = [aws_security_group.da-mlops-test-lb.id]
  subnets            = data.terraform_remote_state.module_outputs.outputs.public_subnet_ids
  tags = {
    Name = "da-mlops-test-lb"
  }
}

# create load balancer listener

resource "aws_lb_listener" "da-mlops-test-lb-listener" {
  load_balancer_arn = aws_lb.da-mlops-test-lb.arn
  port              = 4545
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.da-mlops-test-tg.arn
  }
}

# create load balancer target group attachment

resource "aws_lb_target_group_attachment" "da-mlops-test-tg-attachment" {
  target_group_arn = aws_lb_target_group.da-mlops-test-tg.arn
  target_id        = aws_instance.da-mlops-test-ec2-01.id
  port             = 4545
}

# create security group for ec2 instance

resource "aws_security_group" "da-mlops-test-sg" {
  name        = "da-mlops-test-sg"
  description = "da-mlops-test-sg"
  vpc_id      = data.terraform_remote_state.module_outputs.outputs.vpc_id
  ingress {
    from_port   = 4545
    to_port     = 4545
    protocol    = "tcp"
    security_groups = [aws_security_group.da-mlops-test-lb.id]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "da-mlops-test-sg"
  }
}

resource "aws_instance" "da-mlops-test-ec2-01" {
  ami                    = "ami-091a58610910a87a9"
  instance_type          = "t2.micro"
  key_name               = "da-mlops-test-key"
  subnet_id              = data.terraform_remote_state.module_outputs.outputs.private_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.da-mlops-test-sg.id]
  # create iam instance profile
  # iam_instance_profile = "ec2-ssm-role"
  tags = {
    Name = "da-mlops-test-ec2"
  }
  associate_public_ip_address = false

  #  root volume size gp3

  root_block_device {
    volume_size = 70
    volume_type = "gp3"
    iops = 3000
    throughput = 125
    encrypted = true
    kms_key_id = data.aws_kms_key.default.arn
    tags = {
      Name = "da-mlops-test-ec2-01"
    }

  }

  ebs_block_device {
    device_name = "/dev/sdh"
    volume_size = 8
    volume_type = "gp2"
  }

  # create ec2 instance user data with filebase64encode

  user_data = <<-EOF
              #!/bin/bash
              sudo perl -pi -e 's/^#?Port 22$/Port 4545/' /etc/ssh/sshd_config
              sudo service sshd restart || service ssh restart
              sudo yum update -y
              sudo yum install postgresql15 -y
              EOF
}

