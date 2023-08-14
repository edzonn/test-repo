# create aws opensearch terraform module

module "opensearch" {
  source = "git::github.com/cyberlabrs/terraform-aws-opensearch"

    name = "opensearch"
    domain_name = "opensearch"
    domain_version = "1.0.0"
    instance_type = "t2.small.elasticsearch"
    instance_count = 1
    dedicated_master_enabled = false
    dedicated_master_type = "t2.small.elasticsearch"
    dedicated_master_count = 3
    zone_awareness_enabled = false
    zone_awareness_count = 3
    ebs_volume_type = "gp2"
    ebs_volume_size = 10
    encrypt_at_rest_enabled = false
    encrypt_at_rest_kms_key_id = ""
    node_to_node_encryption_enabled = false
    advanced_options = {}
    log_publishing_options = {}
    vpc_options = {
      subnet_ids = ["subnet-1234567890"]
      security_group_ids = ["sg-1234567890"]
    }
    snapshot_options = {
      automated_snapshot_start_hour = 23
    }
    cognito_options = {
      enabled = false
      user_pool_id = ""
      identity_pool_id = ""
      role_arn = ""
    }
    advanced_security_options = {
      enabled = false
      internal_user_database_enabled = false
      master_user_options = {
        master_user_arn = ""
        master_user_name = ""
        master_user_password = ""
      }
      saml_options = {
        enabled = false
        idp_metadata = ""
        master_user_arn = ""
        master_user_name = ""
        master_user_password = ""
        roles_key = ""
        session_timeout_minutes = 60
        subject_key = ""
        username_key = ""
      }
    }
    tags = {
      Name = "opensearch"
    }
}