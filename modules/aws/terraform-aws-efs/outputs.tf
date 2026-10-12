output "arn" {
    value = try(aws_efs_file_system.efs.arn, null)
}

output "id" {
    value = try(aws_efs_file_system.efs.id, null)
}

output "mount_target_ids" {
    value = try(aws_efs_mount_target.efs.*.id, null)
}

output "security_group_id" {
    value = try(aws_security_group.efs.id, null)
}

output "dns_name" {
    value = try(aws_efs_file_system.efs.dns_name, null)
}
