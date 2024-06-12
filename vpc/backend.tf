terraform {
  backend "s3" {
    bucket = "aws-terraform-tfstatefile-001"
    key = "dev/terraform.statefile"
    region = "ap-southeast-1"

    # dynamodb_table = "dev-test-locktable"
  }
}