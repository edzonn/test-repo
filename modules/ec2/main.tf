resource "aws_instance" "ec2" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.vpc_security_group_ids

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = var.root_volume_type
    iops        = var.root_volume_iops
    throughput  = var.root_volume_throughput
    encrypted   = var.root_volume_encrypted
    kms_key_id  = var.root_volume_kms_key_id
  }

#   ebs_block_device {
#     for_each = var.ebs_block_devices

#     device_name = each.value.device_name
#     volume_size = each.value.volume_size
#     volume_type = each.value.volume_type
#   }

  user_data = var.user_data

  tags = {
    Name = "ec2-instance"
  }
}