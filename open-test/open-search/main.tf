
# data "aws_caller_identity" "current" {}
# data "aws_region" "current" {}

data "terraform_remote_state" "module_outputs" {
  backend = "s3"
  config = {
    bucket = "aws-terraform-tfstatefile-001"
    key    = "dev/terraform.statefile"
    region = "ap-southeast-1"
  }
}

# data "aws_iam_policy_document" "da-mlops-opensearch-policy" {
#   statement {
#     effect = "Allow"

#     principals {
#       type        = "*"
#       identifiers = ["*"]
#     }

#     actions   = ["es:*"]
#     resources = ["arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${local.domain}/*"]
#   }
# }


locals {
  domain        = "da-mlops-${var.service}-engine"
  subnet_ids    = data.terraform_remote_state.module_outputs.outputs.private_subnet_ids
}


resource "aws_security_group" "opensearch_security_group" {
  name = "${local.domain}-sg"
  vpc_id      = data.terraform_remote_state.module_outputs.outputs.vpc_id
  description = "Allow inbound HTTP traffic"

  ingress {
    description = "HTTP from VPC"
    from_port   = 1
    to_port     = 65372
    protocol    = "tcp"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}

# resource "random_password" "password" {
#   length  = 32
#   special = true
# }


# resource "aws_cloudwatch_log_group" "opensearch_log_group_index_slow_logs" {
#   name              = "/aws/opensearch/${local.domain}/index-slow"
#   retention_in_days = 14
# }

# resource "aws_cloudwatch_log_group" "opensearch_log_group_search_slow_logs" {
#   name              = "/aws/opensearch/${local.domain}/search-slow"
#   retention_in_days = 14
# }

# resource "aws_cloudwatch_log_group" "opensearch_log_group_es_application_logs" {
#   name              = "/aws/opensearch/${local.domain}/es-application"
#   retention_in_days = 14
# }

# resource "aws_cloudwatch_log_resource_policy" "opensearch_log_resource_policy" {
#   policy_name = "${local.domain}-domain-log-resource-policy"

#   policy_document = <<CONFIG
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "es.amazonaws.com"
#       },
#       "Action": [
#         "logs:PutLogEvents",
#         "logs:PutLogEventsBatch",
#         "logs:CreateLogStream"
#       ],
#       "Resource": [
#         "${aws_cloudwatch_log_group.opensearch_log_group_index_slow_logs.arn}:*",
#         "${aws_cloudwatch_log_group.opensearch_log_group_search_slow_logs.arn}:*",
#         "${aws_cloudwatch_log_group.opensearch_log_group_es_application_logs.arn}:*"
#       ],
#       "Condition": {
#           "StringEquals": {
#               "aws:SourceAccount": "${data.aws_caller_identity.current.account_id}"
#           },
#           "ArnLike": {
#               "aws:SourceArn": "arn:aws:es:eu-central-1:${data.aws_caller_identity.current.account_id}:domain/${local.domain}"
#           }
#       }
#     }
#   ]
# }
# CONFIG
# }

resource "aws_opensearch_domain" "opensearch" {
  domain_name    = var.domain_name
  engine_version = "OpenSearch_${var.engine_version}"

  cluster_config {
    dedicated_master_count   = var.dedicated_master_count
    dedicated_master_type    = var.dedicated_master_type
    dedicated_master_enabled = var.dedicated_master_enabled
    instance_type            = var.instance_type
    instance_count           = var.instance_count
    zone_awareness_enabled   = var.zone_awareness_enabled
    zone_awareness_config {
      availability_zone_count = var.zone_awareness_enabled ? length(local.subnet_ids) : null
    }
  }

  advanced_security_options {
    enabled                        = var.security_options_enabled
    # anonymous_auth_enabled         = false
    internal_user_database_enabled = true
    master_user_options {
      master_user_name     = var.master_user_name
      master_user_password = var.master_user_password
    }
  }

  encrypt_at_rest {
    enabled = true
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  ebs_options {
    ebs_enabled = var.ebs_enabled
    volume_size = var.ebs_volume_size
    volume_type = var.volume_type
    throughput  = var.throughput
  }



  # log_publishing_options {
  #   cloudwatch_log_group_arn = aws_cloudwatch_log_group.opensearch_log_group_index_slow_logs.arn
  #   log_type                 = "INDEX_SLOW_LOGS"
  # }
  # log_publishing_options {
  #   cloudwatch_log_group_arn = aws_cloudwatch_log_group.opensearch_log_group_search_slow_logs.arn
  #   log_type                 = "SEARCH_SLOW_LOGS"
  # }
  # log_publishing_options {
  #   cloudwatch_log_group_arn = aws_cloudwatch_log_group.opensearch_log_group_es_application_logs.arn
  #   log_type                 = "ES_APPLICATION_LOGS"
  # }

  node_to_node_encryption {
    enabled = true
  }

  vpc_options {
    subnet_ids = local.subnet_ids
    security_group_ids = [aws_security_group.opensearch_security_group.id]
  }


  access_policies = file("${path.module}/iam.json")
}

#   access_policies = var.access_policy == null && var.default_policy_for_fine_grained_access_control ? (<<CONFIG
#     {
#         "Version": "2012-10-17",
#         "Statement": [
#             {
#                 "Action": "es:*",
#                 "Principal": {
#                   "AWS": "*"
#                   },
#                 "Effect": "Allow",
#                 "Resource": "arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${local.domain}/*"
#             }
#         ]
#     }
#     CONFIG 
#   ) : var.access_policy
# }
# resource "aws_ssm_parameter" "opensearch_master_user" {
#   name        = "/service/${var.service}/MASTER_USER"
#   description = "opensearch_password for ${var.service} domain"
#   type        = "SecureString"
#   value       = "${local.master_user},${random_password.password.result}"
# }

