module "nas" {
  source = "../"

  name_postfix = "example"
  size         = 500
  zone         = "KR-1"
}