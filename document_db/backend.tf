terraform {
  backend "s3" {
    bucket = "aws-terraform-tfstatefile-001"
    key = "dev/terraform_docdb.statefile"
    region = "ap-southeast-1"
  }
}

