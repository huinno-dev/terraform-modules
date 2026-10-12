module "vpc" {
  source = "../"

  name              = "seoul-dev-example"
  cidr              = "10.110.0.0/16"
  azs               = ["KR-1", "KR-2"]
  private_subnets   = ["10.110.52.0/22", "10.110.56.0/22"]
  public_subnets    = ["10.110.41.0/24", "10.110.42.0/24"]
  lb_subnets        = ["10.110.71.0/24", "10.110.72.0/24"]
  public_lb_subnets = ["10.110.81.0/24", "10.110.82.0/24"]

  # A NAT gateway needs its own PUBLIC subnet with usage type NATGW.
  enable_nat_gateway = true
  single_nat_gateway = true
  nat_subnets        = ["10.110.91.0/24"]

  network_acl_inbound_rules = [
    {
      priority    = 100
      protocol    = "TCP"
      rule_action = "ALLOW"
      ip_block    = "0.0.0.0/0"
      port_range  = "443"
      description = "accept 443 port"
    },
  ]

  network_acl_outbound_rules = [
    {
      priority    = 100
      protocol    = "TCP"
      rule_action = "ALLOW"
      ip_block    = "0.0.0.0/0"
      port_range  = "1-65535"
      description = "accept 1-65535 port"
    },
  ]
}
