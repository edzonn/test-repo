data "terraform_remote_state" "module_outputs" {
  backend = "s3"
  config = {
    bucket = "aws-terraform-tfstatefile-001"
    key    = "dev/terraform.statefile"
    region = "ap-southeast-1"
  }
}

data "aws_security_group" "alb" {
  id = "sg-0d4904bef0eff785b"
}