module "acg" {
  source = "../"

  name        = "example-acg"
  description = "example acg"
  acg_id      = "30001"
  vpc_id      = var.vpc_id

  inbound_rules = {
    http = {
      protocol    = "TCP"
      ip_block    = "0.0.0.0/0"
      port_range  = "80"
      description = "accept 80 port"
    }
    https = {
      protocol    = "TCP"
      ip_block    = "0.0.0.0/0"
      port_range  = "443"
      description = "accept 443 port"
    }
  }

  outbound_rules = {
    all_tcp = {
      protocol    = "TCP"
      ip_block    = "0.0.0.0/0"
      port_range  = "1-65535"
      description = "accept 1-65535 port"
    }
  }
}