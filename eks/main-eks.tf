
provider "aws" {
  region = "ap-southeast-1"
}

# data "terraform_remote_state" "module_outputs" {
#   backend = "s3"
#   config = {
#     bucket = "da-mlops-test0021-s3-bucket"
#     key    = "dev/terraform.statefile"
#     region = "ap-southeast-1"
#   }
# }

data "terraform_remote_state" "module_outputs" {
  backend = "s3"
  config = {
    bucket = "aws-terraform-tfstatefile-001"
    key    = "dev/terraform.statefile"
    region = "ap-southeast-1"
  }
}

data "aws_ami" "eks_node_gpu" {
  most_recent = true
  # owners      = ["amazon"]
  owners = ["099720109477"]

  filter {
    name   = "name"
    # values = ["amazon-eks-gpu-node-${var.eks_version}*"]
    values = ["ubuntu-eks/k8s_1.27/*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

module "apptier_lt" {
  source        = "/mnt/c/Users/user/Desktop/terraform/test-repo/modules/launch_template"
  name_prefix   = "tf-appserver"
  image_id      = data.aws_ami.eks_node_gpu.image_id
  instance_type = "t2.micro"
  # key_name               = "tf-keypair"
  # instance_profile       = "arn:aws:iam::${var.account_id}:instance-profile/skillup-instanceprofile"
  user_data = filebase64("${path.module}/installer.sh")
  # tags_lt = {
  #   Name = "tf-webtier_lt",
  #   Kind = "practice"
  # }
}


module "eks_managed_node_group" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "19.13"
  cluster_name    = "test-cluster-da"
  cluster_version = "1.27"
  iam_role_name   = "eks-node-group-role"
  subnet_ids      = data.terraform_remote_state.module_outputs.outputs.private_subnet_ids
  # subnet_ids                     = ["subnet-04352532e5e523d82", "subnet-0584f5f975a4ca738", "subnet-0d6433874ca54904e"]
  vpc_id                         = data.terraform_remote_state.module_outputs.outputs.vpc_id
  cluster_endpoint_public_access = true

  node_security_group_additional_rules = {
    # # Control plane invoke Karpenter webhook
    # ingress_karpenter_webhook_tcp = {
    #   description                   = "Control plane invoke Karpenter webhook"
    #   protocol                      = "tcp"
    #   from_port                     = 8443
    #   to_port                       = 8443
    #   type                          = "ingress"
    #   source_cluster_security_group = true
    # },
    # ingress_allow_access_from_control_plane = {
    #   type                          = "ingress"
    #   protocol                      = "tcp"
    #   from_port                     = 9443
    #   to_port                       = 9443
    #   source_cluster_security_group = true
    #   description                   = "Allow access from control plane to webhook port of AWS load balancer controller"
    # },
    # egress_all = {
    #   description = "Node all egress"
    #   protocol    = "-1"
    #   from_port   = 0
    #   to_port     = 0
    #   type        = "egress"
    #   cidr_blocks = ["0.0.0.0/0"]
    #   # ipv6_cidr_blocks = ["::/0"]
    # }

    # egress_rule = {
    #   description = "Node all egress"
    #   protocol    = "-1"
    #   from_port   = 80
    #   to_port     = 80
    #   type        = "egress"
    #   cidr_blocks = ["0.0.0.0/0"]
    # }
  }

  eks_managed_node_groups = {
    one = {
      name = "node-group-1"

      instance_types = ["t3.medium"]
      min_size       = 0
      max_size       = 2
      desired_size   = 0
      capacity_type  = "ON_DEMAND"
      labels = {
        disktype = "test"
      }
      instance_type = "AL2_x86_64_GPU"
      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 20
            volume_type           = "gp2"
            delete_on_termination = true
            # encrypted             = true
            # kms_key_id            = "arn:aws:kms:ap-southeast-1:396246268796:key/d885b304-ea34-41f4-89ab-eece88bfb663"
          }
        }
      }
    }


    two = {
      name = "node-group-2"

      instance_types = ["g4dn.xlarge"]
      min_size       = 1
      max_size       = 2
      desired_size   = 1
      capacity_type  = "ON_DEMAND"
      labels = {
        disktype = "linux"
      }
      ami_type      = "AL2_x86_64_GPU"
      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 20
            volume_type           = "gp2"
            delete_on_termination = true
            # encrypted             = true
            # kms_key_id            = "arn:aws:kms:ap-southeast-1:396246268796:key/d885b304-ea34-41f4-89ab-eece88bfb663"
          }
        }
      }
    }
  }
}

# module "eks_managed_node_group-1" {
#   # source          = "terraform-aws-modules/eks/aws"
#   source = "git@github.com:edzonn/eks-test-1.git"
#   # version         = "19.13.0"
#   cluster_name    = "my-cluster-1"
#   cluster_version = "1.27"
#   iam_role_name   = "eks-node-group-role-1"
#   # subnet_ids      = data.terraform_remote_state.module_outputs.outputs.private_subnet_ids
#   subnet_ids      = data.terraform_remote_state.module_outputs.outputs.database_subnet_private_subnet
#   vpc_id                         = data.terraform_remote_state.module_outputs.outputs.vpc_id
#   cluster_endpoint_public_access = true

#   # create_node_security_group = true

#   node_security_group_additional_rules = {
#     # # Control plane invoke Karpenter webhook
#     # ingress_karpenter_webhook_tcp = {
#     #   description                   = "Control plane invoke Karpenter webhook"
#     #   protocol                      = "tcp"
#     #   from_port                     = 8443
#     #   to_port                       = 8443
#     #   type                          = "ingress"
#     #   source_cluster_security_group = true
#     # },
#     # ingress_allow_access_from_control_plane = {
#     #   type                          = "ingress"
#     #   protocol                      = "tcp"
#     #   from_port                     = 9443
#     #   to_port                       = 9443
#     #   source_cluster_security_group = true
#     #   description                   = "Allow access from control plane to webhook port of AWS load balancer controller"
#     # },
#     egress_all = {
#       description = "Node all egress"
#       protocol    = "-1"
#       from_port   = 0
#       to_port     = 0
#       type        = "egress"
#       cidr_blocks = ["10.10.10.10/32"]
#       # ipv6_cidr_blocks = ["::/0"]
#     }

#     egress_rule = {
#       description = "Node all egress"
#       protocol    = "-1"
#       from_port   = 80
#       to_port     = 80
#       type        = "egress"
#       cidr_blocks = ["10.10.10.11/32"]
#     }
#   }

#   # eks_managed_node_groups = {
#   #   one = {
#   #     name = "node-group-1-1"

#   #     instance_types = ["t3.micro"]
#   #     min_size       = 0
#   #     max_size       = 1
#   #     desired_size   = 0
#   #     capacity_type  = "ON_DEMAND"
#   #     labels = {
#   #       disktype = "test-gpu"
#   #     }
#   #     block_device_mappings = {
#   #       xvda = {
#   #         device_name = "/dev/xvda"
#   #         ebs = {
#   #           volume_size           = 20
#   #           volume_type           = "gp2"
#   #           delete_on_termination = true
#   #           # encrypted             = true
#   #           # kms_key_id            = "arn:aws:kms:ap-southeast-1:396246268796:key/d885b304-ea34-41f4-89ab-eece88bfb663"
#   #         }
#   #       }
#   #     }
#   #   }


#   #   two = {
#   #     name = "node-group-2-1"

#   #     instance_types = ["t3.micro"]
#   #     min_size       = 1
#   #     max_size       = 1
#   #     desired_size   = 1
#   #     capacity_type  = "ON_DEMAND"
#   #     # ami_type = "AL2_x86_64_GPU"
#   #     # ami_id = data.aws_ami.eks_node_gpu.image_id
#   #     labels = {
#   #       disktype = "gpu"
#   #     }
#   #     block_device_mappings = {
#   #       xvda = {
#   #         device_name = "/dev/xvda"
#   #         ebs = {
#   #           volume_size           = 20
#   #           volume_type           = "gp2"
#   #           delete_on_termination = true
#   #           # encrypted             = true
#   #           # kms_key_id            = "arn:aws:kms:ap-southeast-1:396246268796:key/d885b304-ea34-41f4-89ab-eece88bfb663"
#   #         }
#   #       }
#   #     }
#   #   }
#   # }
# }

#  resource "aws_iam_role" "example" {
#    name = "example"
#    force_detach_policies = true
#    assume_role_policy = jsonencode({
#      Version = "2012-10-17"
#      Statement = [
#        {
#          Action = "sts:AssumeRole"
#          Effect = "Allow"
#          Principal = {
#            Service = "ec2.amazonaws.com"
#          }
#        },
#      ]
#    })
#  }

#   resource "aws_iam_role" "da-mlops-test001-s3-bucket-role-1" {
#    name = "example"
#    force_detach_policies = true
#    assume_role_policy = jsonencode({
#      Version = "2012-10-17"
#      Statement = [
#        {
#          Action = "sts:AssumeRole"
#          Effect = "Allow"
#          Principal = {
#            Service = "s3.amazonaws.com"
#          }
#        },
#      ]
#    })
#  }

#  resource "aws_iam_role_policy_attachment" "example-AmazonEKSWorkerNodePolicy" {
#    role       = aws_iam_role.example.name
#    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
#  }
#  resource "aws_iam_role_policy_attachment" "example-AmazonEKS_CNI_Policy" {
#    role       = aws_iam_role.example.name
#    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
#  }
#  resource "aws_iam_role_policy_attachment" "example-AmazonEC2ContainerRegistryReadOnly" {
#    role       = aws_iam_role.example.name
#    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
#  }

#  resource "aws_iam_instance_profile" "example_instance_profile" {
#   name = "example-instance-profile"
#   role = aws_iam_role.example.name
# }




# resource "aws_launch_template" "eks_nodes" {
#   name_prefix   = "eks_nodes"
#   image_id      = data.aws_ami.eks_node_gpu.image_id
#   instance_type = "t3.micro"

#   block_device_mappings {
#     device_name = "/dev/xvda"

#     ebs {
#       volume_size           = 20
#       volume_type           = "gp2"
#       delete_on_termination = true
#     }
#   }

#   # instance_initiated_shutdown_behavior = "terminate"

#   # update_default_version = true
#   # metadata_options {
#   #   http_endpoint               = "enabled"
#   #   http_tokens                 = "optional"
#   #   http_put_response_hop_limit = 2
#   # }

# #   vpc_security_group_ids = [module.eks_managed_node_group.node_security_group_id]

#   user_data = filebase64("${path.module}/installer.sh")
# }

# resource "aws_eks_node_group" "example" {
#   cluster_name    = module.eks_managed_node_group-1.cluster_name
#   node_group_name = "example"
#   node_role_arn   = aws_iam_role.example.arn
#   subnet_ids      = data.terraform_remote_state.module_outputs.outputs.database_subnet_private_subnet

#   scaling_config {
#     desired_size = 1
#     max_size     = 1
#     min_size     = 1
#   }

#   launch_template {
#     id      = aws_launch_template.eks_nodes.id
#     version = aws_launch_template.eks_nodes.latest_version
#   }

#     depends_on = [
#     aws_iam_role_policy_attachment.example-AmazonEKSWorkerNodePolicy,
#     aws_iam_role_policy_attachment.example-AmazonEKS_CNI_Policy,
#     aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly,
#   ]

# }

