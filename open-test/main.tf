
data "terraform_remote_state" "module_outputs" {
  backend = "s3"
  config = {
    bucket = "da-mlops-test0021-s3-bucket"
    key    = "dev/terraform.statefile"
    region = "ap-southeast-1"
  }
}


data "terraform_remote_state" "route53" {
  backend = "local"
  config = {
    path = "../route53/terraform.tfstate"
  }
}


module "opensearch" {
  source = "../open-test/open-search"
  vpc    = data.terraform_remote_state.module_outputs.outputs.vpc_id
  # get data from statefile route53_zone_id
  hosted_zone_name         = data.terraform_remote_state.route53.outputs.route53_zone_name
  engine_version           = "2.3"
  security_options_enabled = true
  volume_type              = "gp3"
  throughput               = 250
  ebs_enabled              = true
  ebs_volume_size          = 45
  service                  = "opensearch"
  instance_type            = "m6g.large.search"
  instance_count           = 3
  dedicated_master_enabled = true
  dedicated_master_count   = 3
  dedicated_master_type    = "m6g.large.search"
  zone_awareness_enabled   = true
}






