output "acg_id" {
  description = "The ID of the access control group"
  value       = data.ncloud_access_control_group.this.id
}

output "acg_no" {
  description = "The number of the access control group (same value as `acg_id`)"
  value       = data.ncloud_access_control_group.this.access_control_group_no
}

output "acg_name" {
  description = "The name of the access control group"
  value       = data.ncloud_access_control_group.this.name
}

output "acg_rule_id" {
  description = "The ID of the ACG rule set managed by this module"
  value       = try(ncloud_access_control_group_rule.this[0].id, null)
}
