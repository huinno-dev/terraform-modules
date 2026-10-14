module "alb_ingress" {
  source = "../"

  # Same namespace as the Traefik Service.
  namespace = "kube-ingress"

  lb_name        = "example-alb"
  certificate_no = "<certificate-no>"
  # From terraform-ncloud-public-ip; in Terragrunt:
  #   dependency.public_ip.outputs.public_ip_nos["alb"]
  public_ip_instance_no = "<public-ip-instance-no>"
}

output "lb_address" {
  value = module.alb_ingress.lb_address
}
