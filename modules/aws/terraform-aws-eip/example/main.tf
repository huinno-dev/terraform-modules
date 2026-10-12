module "eip" {
  source = "../"

  name = "seoul-dev-nat"
  azs  = ["ap-northeast-2a", "ap-northeast-2c"]

  tags = {
    Environment = "dev"
  }
}
