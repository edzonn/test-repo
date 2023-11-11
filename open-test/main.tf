
data "terraform_remote_state" "module_outputs" {
  backend = "s3"
  config = {
    bucket = "da-mlops-test0021-s3-bucket"
    key    = "dev/terraform.statefile"
    region = "ap-southeast-1"
  }
}

module "opensearch" {
  source = "../open-test/open-search"
  vpc    = data.terraform_remote_state.module_outputs.outputs.vpc_id
  # get data from statefile route53_zone_id
  hosted_zone_name         = "test-domain-001"
  domain_name              = "test-domain-001"
  engine_version           = "2.3"
  security_options_enabled = true
  volume_type              = "gp3"
  throughput               = 250
  ebs_enabled              = true
  ebs_volume_size          = 45
  volume_size_auto_resize  = true
  service                  = "opensearch"
  instance_type            = "m6g.large.search"
  instance_count           = 3
  dedicated_master_enabled = true
  dedicated_master_count   = 3
  dedicated_master_type    = "m6g.large.search"
  zone_awareness_enabled   = true
  default_policy_for_fine_grained_access_control = true
  master_user_name     = "root"
  master_user_password = "P4ssw0rd123@"
}






