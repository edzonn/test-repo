terraform {
  backend "s3" {
    bucket = "da-mlops-test0021-s3-bucket"
    key    = "dev/terraform-eks.statefile"
    region = "ap-southeast-1"

    # dynamodb_table = "dev-test-locktable"
  }
}