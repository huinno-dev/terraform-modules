module "public_ip" {
  source = "../"

  public_ips = {
    # Used by the ALB Ingress (terraform-ncloud-nks-alb-ingress
    # `public_ip_instance_no`).
    alb = {
      description = "ALB public IP for seoul-dev-example"
    }
  }
}

output "public_ips" {
  value = module.public_ip.public_ips
}
