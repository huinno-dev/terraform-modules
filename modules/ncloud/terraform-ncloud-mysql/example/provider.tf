provider "ncloud" {
  support_vpc = true
  site        = var.site
  region      = var.region
  access_key  = var.ncloud_access_key
  secret_key  = var.ncloud_secret_key
}
