resource "aws_efs_mount_target" "this" {
  count           = length(var.subnet_ids)
  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = var.subnet_ids[count.index]
  security_groups = [var.security_group_id]
}

resource "aws_efs_file_system" "this" {
  creation_token = var.efs_name
  kms_key_id     = var.kms_key_id
  encrypted      = true

    lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
}