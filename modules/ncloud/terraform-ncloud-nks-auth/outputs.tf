output "config_map_name" {
  description = "Name of the managed ConfigMap"
  value       = kubernetes_config_map_v1.this.metadata[0].name
}
