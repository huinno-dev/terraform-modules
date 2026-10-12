output "nas_id" {
  description = "The ID of the NAS volume"
  value       = try(ncloud_nas_volume.this[0].id, null)
}

output "nas_volume_no" {
  description = "The number of the NAS volume (same value as `nas_id`)"
  value       = try(ncloud_nas_volume.this[0].nas_volume_no, null)
}

output "nas_name" {
  description = "The full name of the NAS volume"
  value       = try(ncloud_nas_volume.this[0].name, null)
}

output "nas_mount_info" {
  description = "Mount information for the NAS volume"
  value       = try(ncloud_nas_volume.this[0].mount_information, null)
}

output "nas_volume_total_size" {
  description = "Total size of the NAS volume, in GiB"
  value       = try(ncloud_nas_volume.this[0].volume_total_size, null)
}

output "nas_snapshot_volume_size" {
  description = "Snapshot volume size, in GiB"
  value       = try(ncloud_nas_volume.this[0].snapshot_volume_size, null)
}

output "nas_is_snapshot_configuration" {
  description = "Whether a snapshot volume is configured"
  value       = try(ncloud_nas_volume.this[0].is_snapshot_configuration, null)
}

output "nas_is_event_configuration" {
  description = "Whether the event configuration is set"
  value       = try(ncloud_nas_volume.this[0].is_event_configuration, null)
}
