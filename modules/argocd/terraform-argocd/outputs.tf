output "repositories" {
  description = "Map of repository key to the registered repository."
  value       = argocd_repository.this
  sensitive   = true
}

output "repository_connection_states" {
  description = "Map of repository key to its connection state."
  value       = { for k, r in argocd_repository.this : k => r.connection_state_status }
}

output "projects" {
  description = "Map of project key to the created AppProject."
  value       = argocd_project.this
}

output "project_names" {
  description = "Map of project key to the AppProject name."
  value       = { for k, p in argocd_project.this : k => p.metadata[0].name }
}

output "applications" {
  description = "Map of application key to the created Application."
  value       = argocd_application.this
}

output "application_names" {
  description = "Map of application key to the Application name."
  value       = { for k, a in argocd_application.this : k => a.metadata[0].name }
}
