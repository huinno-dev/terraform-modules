module "alb_ingress" {
  source = "../"

  # Same namespace as the Traefik Service.
  namespace = "kube-ingress"

  lb_name               = "example-alb"
  certificate_no        = "<certificate-no>"
  public_ip_instance_no = "<public-ip-instance-no>"
}

output "lb_address" {
  value = module.alb_ingress.lb_address
}
