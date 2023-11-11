module "vpc" {
  source               = "/mnt/c/Users/user/Desktop/terraform/test-repo/modules/vpc"
  vpc_name             = "example"
  vpc_cidr_block       = "10.22.0.0/16"
  azs                  =["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
  public_subnet_cidrs  = ["10.22.48.0/24", "10.22.49.0/24", "10.22.50.0/24"]
  private_subnet_cidrs = ["10.22.0.0/24", "10.22.16.0/24", "10.22.32.0/24"]
  database_subnet_cidrs =  ["10.22.51.0/24", "10.22.52.0/24", "10.22.53.0/24"]
}


