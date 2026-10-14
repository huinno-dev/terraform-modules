locals {
  prefix = "alb.ingress.kubernetes.io"
  https  = var.certificate_no != null

  # Null values are dropped so unset options fall back to controller defaults.
  generated_annotations = {
    for k, v in {
      "${local.prefix}/load-balancer-name"    = var.lb_name
      "${local.prefix}/network-type"          = var.network_type
      "${local.prefix}/listen-ports"          = local.https ? "[{\"HTTP\": 80},{\"HTTPS\": 443}]" : "[{\"HTTP\": 80}]"
      "${local.prefix}/ssl-certificate-no"    = var.certificate_no
      "${local.prefix}/ssl-min-version"       = local.https ? var.ssl_min_version : null
      "${local.prefix}/ssl-redirect"          = local.https ? "443" : null
      "${local.prefix}/healthcheck-path"      = var.healthcheck_path
      "${local.prefix}/public-ip-instance-no" = var.public_ip_instance_no

      "${local.prefix}/ncloud-load-balancer-retain-public-ip-on-termination" = tostring(var.retain_public_ip)
    } : k => v if v != null
  }

  annotations = merge(local.generated_annotations, var.extra_annotations)
}
