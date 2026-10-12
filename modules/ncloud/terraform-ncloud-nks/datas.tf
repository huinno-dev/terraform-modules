data "ncloud_vpc" "this" {
  id = var.vpc_id
}

data "ncloud_nks_versions" "this" {
  hypervisor_code  = var.hypervisor_code
  regional_support = var.regional ? true : null

  filter {
    name   = "value"
    values = [var.cluster_version]
    regex  = true
  }
}

# Node pool image / spec lookup. `ncloud_nks_server_images` and
# `ncloud_nks_server_products` are the NKS-specific data sources; the generic
# `ncloud_server_image` / `ncloud_server_product` ones do not return the codes
# NKS accepts.
data "ncloud_nks_server_images" "this" {
  hypervisor_code = var.hypervisor_code

  filter {
    name   = "label"
    values = [var.server_image_name]
    regex  = true
  }
}

data "ncloud_nks_server_products" "this" {
  software_code = data.ncloud_nks_server_images.this.images[0].value
  zone          = local.node_pool_zone

  dynamic "filter" {
    for_each = var.selectors
    content {
      name   = filter.value.name
      values = filter.value.value
      regex  = try(filter.value.regex, null)
    }
  }
}

data "ncloud_nks_kube_config" "this" {
  cluster_uuid = ncloud_nks_cluster.this.uuid
}
