terraform {
  backend "s3" {
    bucket = "aws-terraform-tfstatefile-001"
    key = "dev/terraform_alb.statefile"
    region = "ap-sout-1"
  }
}