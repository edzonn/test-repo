output "efs_id" {
  description = "The ID of the EFS file system"
  value       = aws_efs_file_system.this.id
}

output "mount_target_ids" {
  description = "The IDs of the EFS mount targets"
  value       = aws_efs_mount_target.this.*.id
}