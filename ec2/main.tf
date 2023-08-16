# create ec2 instane main.terraform {
provider "aws" {
  region = "ap-southeast-1"
}

data "terraform_remote_state" "module_outputs" {
  backend = "s3"
  config = {
    bucket = "da-mlops-test0021-s3-bucket"
    key    = "dev/terraform.statefile"
    region = "ap-southeast-1"
  }
}

# create security group for ec2 instance

resource "aws_security_group" "da-mlops-test-sg" {
  name        = "da-mlops-test-sg"
  description = "da-mlops-test-sg"
  vpc_id      = data.terraform_remote_state.module_outputs.outputs.vpc_id
  ingress {
    from_port   = 22
    to_port     = 22
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
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "da-mlops-test-sg"
  }
}



resource "aws_instance" "da-mlops-test-ec2" {
  ami                    = "ami-091a58610910a87a9"
  instance_type          = "t2.micro"
  key_name               = "da-mlops-test-key"
  subnet_id              = data.terraform_remote_state.module_outputs.outputs.public_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.da-mlops-test-sg.id]
  tags = {
    Name = "da-mlops-test-ec2"
  }
  # create ec2 instance public ip
  associate_public_ip_address = true

}

