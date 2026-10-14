locals {
  # Control plane spec per hypervisor, keyed by max node count.
  cluster_types = {
    XEN = {
      "10" = "SVR.VNKS.STAND.C002.M008.NET.SSD.B050.G002"
      "50" = "SVR.VNKS.STAND.C004.M016.NET.SSD.B050.G002"
    }
    RHV = {
      "10" = "SVR.VNKS.STAND.C002.M008.NET.SSD.B050.G002"
      "50" = "SVR.VNKS.STAND.C004.M016.NET.SSD.B050.G002"
    }
    KVM = {
      "250" = "SVR.VNKS.STAND.C004.M016.G003"
    }
  }

  cluster_type_default = var.hypervisor_code == "KVM" ? "SVR.VNKS.STAND.C004.M016.G003" : "SVR.VNKS.STAND.C002.M008.NET.SSD.B050.G002"
  cluster_type         = lookup(local.cluster_types[var.hypervisor_code], var.cluster_type, local.cluster_type_default)

  is_kvm = var.hypervisor_code == "KVM"

  node_pool_zone = var.node_pool_zone != "" ? var.node_pool_zone : var.az

  subnet_no_list = length(var.subnet_no_list) > 0 ? var.subnet_no_list : [var.private_subnet_id]

  node_pool_subnet_no_list = length(var.node_pool_subnet_no_list) > 0 ? var.node_pool_subnet_no_list : local.subnet_no_list

  # Top-level variables: the `default` pool, and defaults for `node_pools`.
  default_node_pool = {
    name              = var.node_pool_name != "" ? var.node_pool_name : var.name
    version           = var.node_pool_version
    subnet_no_list    = local.node_pool_subnet_no_list
    zone              = local.node_pool_zone
    server_image_name = var.server_image_name
    selectors         = var.selectors
    storage_size      = var.storage_size
    server_role_id    = var.server_role_id
    node_count        = var.node_count
    enable_asg        = var.enable_asg
    min               = var.min
    max               = var.max
    node_labels       = null
    node_taints       = null
    timeouts          = var.node_pool_timeouts
  }

  # No `cond ? map : map` here: pools with different attributes can't unify.
  node_pools_input = merge(
    { for k in(length(var.node_pools) > 0 ? [] : ["default"]) : k => {} },
    var.node_pools,
  )

  node_pools = {
    for k, v in local.node_pools_input : k => merge(
      local.default_node_pool,
      { name = length(var.node_pools) > 0 ? k : local.default_node_pool.name },
      v,
    )
  }

  # `value` is the spec code on KVM, the product code on XEN / RHV.
  node_pool_products  = { for k, d in data.ncloud_nks_server_products.this : k => d.products[0].value }
  node_pool_softwares = { for k, d in data.ncloud_nks_server_images.this : k => d.images[0].value }
}
