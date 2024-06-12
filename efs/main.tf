# data "aws_kms_key" "this" {
#   key_id = "aws/elasticfilesystem"
# }

data "terraform_remote_state" "module_outputs" {
  backend = "s3"
  config = {
    bucket = "aws-terraform-tfstatefile-001"
    key    = "dev/terraform.statefile"
    region = "ap-southeast-1"
  }
}

module "efs" {
  source            = "/mnt/c/Users/user/Desktop/terraform/test-repo/modules/efs"
  efs_name          = "my-efs"
  subnet_ids        = data.terraform_remote_state.module_outputs.outputs.private_subnet_ids
  security_group_id = "sg-0a84e76479639d970"
  kms_key_id        = "arn:aws:kms:ap-southeast-1:092744370500:key/7f78820d-cd44-4ba1-9523-76f7a65673f8"
  vpc_cidr         = data.terraform_remote_state.module_outputs.outputs.vpc_id
}