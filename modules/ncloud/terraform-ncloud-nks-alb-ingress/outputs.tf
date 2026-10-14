output "ingress_name" {
  description = "Ingress name"
  value       = kubernetes_ingress_v1.this.metadata[0].name
}

output "lb_address" {
  description = "ALB address published on the Ingress (hostname, or IP when no hostname)"
  value = try(
    coalesce(
      kubernetes_ingress_v1.this.status[0].load_balancer[0].ingress[0].hostname,
      kubernetes_ingress_v1.this.status[0].load_balancer[0].ingress[0].ip,
    ),
    null,
  )
}

output "annotations" {
  description = "Annotations applied to the Ingress"
  value       = local.annotations
}
