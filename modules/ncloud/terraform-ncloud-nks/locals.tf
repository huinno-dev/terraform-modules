locals {
  # Control plane sizing. The code differs per hypervisor, and the key is the
  # maximum number of nodes the control plane can carry.
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

  # `ncloud_nks_server_products` returns the spec code for KVM and the product
  # code for XEN / RHV in the same `value` field.
  node_pool_product  = data.ncloud_nks_server_products.this.products[0].value
  node_pool_software = data.ncloud_nks_server_images.this.images[0].value

  subnet_no_list = length(var.subnet_no_list) > 0 ? var.subnet_no_list : [var.private_subnet_id]

  node_pool_subnet_no_list = length(var.node_pool_subnet_no_list) > 0 ? var.node_pool_subnet_no_list : local.subnet_no_list

  ncloud_auth_configmap_data = {
    mapSubAccounts = yamlencode(var.ncloud_auth_accounts)
  }
}
