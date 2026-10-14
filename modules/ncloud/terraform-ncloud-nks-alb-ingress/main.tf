# The controller's install manifest makes its class the cluster default, which
# would send every class-less Ingress to it and create one ALB per Ingress.
resource "kubernetes_annotations" "ingress_class" {
  count = var.unset_default_ingress_class ? 1 : 0

  api_version = "networking.k8s.io/v1"
  kind        = "IngressClass"

  metadata {
    name = var.ingress_class_name
  }

  annotations = {
    "ingressclass.kubernetes.io/is-default-class" = "false"
  }

  # The field is owned by the install manifest.
  force = true
}

# The ALB Ingress Controller creates and owns one ALB for this Ingress and
# sends every request to `backend_service`.
resource "kubernetes_ingress_v1" "this" {
  metadata {
    name        = var.name
    namespace   = var.namespace
    annotations = local.annotations
  }

  spec {
    ingress_class_name = var.ingress_class_name

    default_backend {
      service {
        name = var.backend_service

        port {
          number = var.backend_port
        }
      }
    }
  }

  wait_for_load_balancer = var.wait_for_load_balancer

  lifecycle {
    # Deleting the Ingress deletes the ALB.
    prevent_destroy = true
  }
}
