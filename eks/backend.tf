# terraform {
#   backend "s3" {
#     bucket = "da-mlops-test0021-s3-bucket"
#     key    = "dev/terraform-eks.statefile"
#     region = "ap-southeast-1"

#     # dynamodb_table = "dev-test-locktable"
#   }
# }

terraform {
  backend "s3" {
    bucket = "aws-terraform-tfstatefile-001"
    key    = "dev/terraform-eks-test.statefile"
    region = "ap-southeast-1"

    # dynamodb_table = "dev-test-locktable"
  }
}