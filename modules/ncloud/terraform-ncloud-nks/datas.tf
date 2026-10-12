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

# Per node pool image / spec lookup. Use the NKS data sources; the generic
# server ones return codes NKS rejects.
data "ncloud_nks_server_images" "this" {
  for_each = local.node_pools

  hypervisor_code = var.hypervisor_code

  filter {
    name   = "label"
    values = [each.value.server_image_name]
    regex  = true
  }
}

data "ncloud_nks_server_products" "this" {
  for_each = local.node_pools

  software_code = data.ncloud_nks_server_images.this[each.key].images[0].value
  zone          = each.value.zone

  dynamic "filter" {
    for_each = each.value.selectors
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
