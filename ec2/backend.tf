terraform {
  backend "s3" {
    bucket = "aws-terraform-tfstatefile-001"
    key = "dev/terraform_ec2.statefile"
    region = "ap-southeast-1"
  }
}