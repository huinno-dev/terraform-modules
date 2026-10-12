output "deployment" {
  description = "Map of outputs of a wrapper."
  value       = helm_release.this
  sensitive   = true
}

output "metadata" {
  description = "Map of release key to the deployed release metadata (chart, version, app_version, revision, namespace)."
  value       = { for k, r in helm_release.this : k => r.metadata }
}

output "status" {
  description = "Map of release key to release status."
  value       = { for k, r in helm_release.this : k => r.status }
}
