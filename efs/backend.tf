terraform {
  backend "s3" {
    bucket = "aws-terraform-tfstatefile-001"
    key    = "dev/terraform-efs-test.statefile"
    region = "ap-southeast-1"

    # dynamodb_table = "dev-test-locktable"
  }
}

# provider "availability" {
#   region = "ap-southeast-1"
# }