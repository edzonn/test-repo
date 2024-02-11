
resource "aws_efs_file_system" "file_system" {
  creation_token                  = var.creation_token
  encrypted                       = var.encrypted
  kms_key_id                      = var.encrypted && var.kms_key_id != null ? var.kms_key_id : null
  performance_mode                = var.performance_mode
  throughput_mode                 = var.throughput_mode
  provisioned_throughput_in_mibps = var.throughput_mode == "provisioned" ? var.provisioned_throughput_in_mibps : null
  tags                            = var.tags
  lifecycle_policy {
    transition_to_ia = var.lifecycle_policy
  }
}

resource "aws_efs_mount_target" "alpha" {
  file_system_id = aws_efs_file_system.file_system.id
  subnet_id      = var.subnet_id
}

# data "availability_zones" "available" {}

# resource "aws_efs_file_system" "efs" {
#   creation_token   = "efs"
#   performance_mode = "generalPurpose"
#   throughput_mode  = "bursting"
#   encrypted        = "true"
#   tags = {
#     Name = "EFS"
#   }
# }


# resource "aws_efs_mount_target" "efs-mt" {
#   #    count = length(data.aws_availability_zones.available.names)
#   file_system_id  = aws_efs_file_system.efs.id
#   subnet_id       = data.terraform_remote_state.module_outputs.outputs.private_subnet_ids.count > 0 ? data.terraform_remote_state.module_outputs.outputs.private_subnet_ids[count.index] : data.terraform_remote_state.module_outputs.outputs.public_subnet_ids[count.index]
#   security_groups = data.terraform_remote_state.module_outputs.outputs.security_group_ids
# }

# resource "aws_security_group" "ec2" {
#   name        = "allow_efs"
#   description = "Allow efs outbound traffic"
#   vpc_id      = data.terraform_remote_state.module_outputs.outputs.vpc_id
#   ingress {
#     cidr_blocks = ["0.0.0.0/0"]
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#   }
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   tags = {
#     Name = "allow_efs"
#   }
# }

# resource "aws_security_group" "efs" {
#   name        = "efs-sg"
#   description = "Allos inbound efs traffic from ec2"
#   vpc_id      = data.terraform_remote_state.module_outputs.outputs.vpc_id

#   ingress {
#     security_groups = [aws_security_group.ec2.id]
#     from_port       = 2049
#     to_port         = 2049
#     protocol        = "tcp"
#   }

#   egress {
#     security_groups = [aws_security_group.ec2.id]
#     from_port       = 0
#     to_port         = 0
#     protocol        = "-1"
#   }
# }