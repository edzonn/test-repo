# create documentdb cluster and parameter
data "terraform_remote_state" "module_outputs" {
  backend = "s3"
  config = {
    bucket = "da-mlops-test0021-s3-bucket"
    key    = "dev/terraform.statefile"
    region = "ap-southeast-1"
  }
}

resource "aws_docdb_cluster_parameter_group" "da-mlops-test-docdb-param" {
    family = "docdb3.6"
    name   = "da-mlops-test-docdb-param"
    parameters = {
        "audit_logs.role_arn" = "arn:aws:iam::${var.account_id}:role/da-mlops-test-docdb-role"
        "audit_logs.enabled" = "true"
        "tls[0]" = "disabled"
    }
    tags = {
        Name = "da-mlops-test-docdb-param"
    }
}

# AWS DocumentDB Cluster

resource "aws_docdb_cluster" "da-mlops-test-docdb" {
    cluster_identifier         = "da-mlops-test-docdb"
    engine                     = "docdb"
    master_username            = "docdbadmin"
    master_password            = "docdbadmin"
    apply_immediately          = true
    skip_final_snapshot       = true
    db_subnet_group_name      = aws_db_subnet_group.da-mlops-test-docdb-subnet-group.name
    vpc_security_group_ids    = [aws_security_group.da-mlops-test-docdb-sg.id]
    cluster_parameter_group_name = aws_docdb_cluster_parameter_group.da-mlops-test-docdb-param.name
    tags = {
        Name = "da-mlops-test-docdb"
    }
}

# create documentdb subnet group

# resource "aws_db_subnet_group" "da-mlops-test-docdb-subnet-group" {
#     name = "da-mlops-test-docdb-subnet-group"
#     subnet_ids = aws_subnet.da-mlops-test-private-subnet.*.id
#     tags = {
#         Name = "da-mlops-test-docdb-subnet-group"
#     }
# }

resource "aws_db_subnet_group" "da-mlops-test-docdb-subnet-group" {
    name = "da-mlops-test-docdb-subnet-group"
    # subnet_ids for statefile

    subnet_ids = data.terraform_remote_state.module_outputs.outputs.database_subnet_private_subnet
    tags = {
        Name = "da-mlops-test-docdb-subnet-group"
    }
}


# create documentdb security group

resource "aws_security_group" "da-mlops-test-docdb-sg" {
    name = "da-mlops-test-docdb-sg"
    description = "da-mlops-test-docdb-sg"
    vpc_id = data.terraform_remote_state.module_outputs.outputs.vpc_id
    ingress {
        from_port = 27017
        to_port = 27017
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/16"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/16"]
    }
    tags = {
        Name = "da-mlops-test-docdb-sg"
    }
}

# create documentdb role

resource "aws_iam_role" "da-mlops-test-docdb-role" {
    name = "da-mlops-test-docdb-role"
    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "docdb.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}

EOF
    tags = {
        Name = "da-mlops-test-docdb-role"
    }
}

# create documentdb role policy

resource "aws_iam_role_policy" "da-mlops-test-docdb-role-policy" {
    name = "da-mlops-test-docdb-role-policy"
    role = aws_iam_role.da-mlops-test-docdb-role.id
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:*:*:*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "logs:CreateLogGroup"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}

EOF
}



