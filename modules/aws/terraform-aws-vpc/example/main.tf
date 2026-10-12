module "vpc" {
  source = "../"

  name            = "seoul-dev"
  cidr            = "10.120.0.0/16"
  azs             = ["ap-northeast-2a", "ap-northeast-2c"]
  public_subnets  = ["10.120.1.0/24", "10.120.2.0/24"]
  private_subnets = ["10.120.11.0/24", "10.120.12.0/24"]

  enable_dns_hostnames = true

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Environment = "dev"
  }
}
