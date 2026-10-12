resource "ncloud_load_balancer_ssl_certificate" "this" {
  for_each = var.certificate

  certificate_name      = try(each.value.name, null)
  privatekey            = file(try(each.value.privatekey, null))
  publickey_certificate = file(try(each.value.publickey, null))
  certificate_chain     = file(try(each.value.chain, null))
}