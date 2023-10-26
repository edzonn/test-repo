terraform {
  backend "s3" {
    bucket = "da-mlops-test0021-s3-bucket"
    key = "dev/open-search-terraform.statefile"
    region = "ap-southeast-1"

    # dynamodb_table = "dev-test-locktable"
  }
}