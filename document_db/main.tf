# create documentdb cluster and parameter
data "terraform_remote_state" "module_outputs" {
  backend = "s3"
  config = {
    bucket = "aws-terraform-tfstatefile-001"
    key    = "dev/terraform.statefile"
    region = "ap-southeast-1"
  }
}

resource "aws_docdb_cluster_parameter_group" "da-mlops-test-docdb-param" {
    family = var.family
    name = var.name
    # # parameter_group_name = var.parameter_group_name
     parameter {
    #     name = "audit_logs.role_arn"
         name = "tls"
    #     value = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/da-mlops-test-docdb-role"
         value = "enabled"
         apply_method = "immediate"
     }
}

resource "aws_docdb_cluster" "da-mlops-test-docdb" {
    cluster_identifier         = var.cluster_identifier
    engine                     = var.engine
    master_username            = var.master_username
    master_password            = var.master_password
    apply_immediately          = var.apply_immediately   
    skip_final_snapshot       = var.skip_final_snapshot
    db_subnet_group_name      = aws_db_subnet_group.da-mlops-test-docdb-subnet-group.name
    vpc_security_group_ids    = [aws_security_group.da-mlops-test-docdb-sg.id]
    # cluster_parameters = var.cluster_parameters
    tags = {
        Name = "da-mlops-test-docdb"
    }
}

resource "aws_docdb_cluster_instance" "da-mlops-test-docdb-instance" {
    identifier = var.identifier
    # engine_version = var.engine_version
    cluster_identifier = aws_docdb_cluster.da-mlops-test-docdb.id
    instance_class = var.instance_class
    ca_cert_identifier = "rds-ca-rsa2048-g1"
    apply_immediately = true
    tags = {
        Name = "da-mlops-test-docdb-instance"
    }
}

resource "aws_docdb_cluster_instance" "da-mlops-test-docdb-instance-2" {
    identifier = var.identifier-2
    # engine_version = var.engine_version
    cluster_identifier = aws_docdb_cluster.da-mlops-test-docdb.id
    instance_class = var.instance_class
    ca_cert_identifier = "rds-ca-rsa2048-g1"
    apply_immediately = true
    tags = {
        Name = "da-mlops-test-docdb-instance"
    }
}

resource "aws_docdb_cluster_instance" "da-mlops-test-docdb-instance-3" {
    identifier = var.identifier-3
    # engine_version = var.engine_version
    cluster_identifier = aws_docdb_cluster.da-mlops-test-docdb.id
    instance_class = var.instance_class
    ca_cert_identifier = "rds-ca-rsa2048-g1"
    apply_immediately = true
    tags = {
        Name = "da-mlops-test-docdb-instance"
    }
}

resource "aws_db_subnet_group" "da-mlops-test-docdb-subnet-group" {
    name = "da-mlops-test-docdb-subnet-group"
    # subnet_ids for statefile

    subnet_ids = data.terraform_remote_state.module_outputs.outputs.database_subnet_private_subnet
    tags = {
        Name = "da-mlops-test-docdb-subnet-group"
    }
}

resource "aws_security_group" "da-mlops-test-docdb-sg" {
    name = "da-mlops-test-docdb-sg"
    description = "da-mlops-test-docdb-sg"
    vpc_id = data.terraform_remote_state.module_outputs.outputs.vpc_id
    ingress {
        from_port = 27017
        to_port = 27017
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "da-mlops-test-docdb-sg"
    }
}

# resource "aws_iam_role" "da-mlops-test-docdb-role" {
#     name = "da-mlops-test-docdb-role"
#     assume_role_policy = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Action": "sts:AssumeRole",
#             "Principal": {
#                 "Service": "docdb.amazonaws.com"
#             },
#             "Effect": "Allow",
#             "Sid": ""
#         }
#     ]
# }

# EOF
#     tags = {
#         Name = "da-mlops-test-docdb-role"
#     }
# }

# resource "aws_iam_role_policy" "da-mlops-test-docdb-role-policy" {
#     name = "da-mlops-test-docdb-role-policy"
#     role = aws_iam_role.da-mlops-test-docdb-role.id
#     policy = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Action": [
#                 "logs:CreateLogStream",
#                 "logs:PutLogEvents"
#             ],
#             "Resource": "arn:aws:logs:*:*:*",
#             "Effect": "Allow"
#         },
#         {
#             "Action": [
#                 "logs:CreateLogGroup"
#             ],
#             "Resource": "*",
#             "Effect": "Allow"
#         }
#     ]
# }

# EOF
# }