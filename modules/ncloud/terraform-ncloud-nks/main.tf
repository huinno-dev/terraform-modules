resource "ncloud_nks_cluster" "this" {
  name                 = var.name
  hypervisor_code      = var.hypervisor_code
  cluster_type         = local.cluster_type
  k8s_version          = data.ncloud_nks_versions.this.versions[0].value
  login_key_name       = var.key_name
  kube_network_plugin  = var.network_plugin
  vpc_no               = data.ncloud_vpc.this.id
  subnet_no_list       = local.subnet_no_list
  lb_private_subnet_no = var.lb_subnet_id
  lb_public_subnet_no  = var.public_lb_subnet_id

  regional = var.regional 
  zone     = var.regional ? null : var.az

  public_network        = var.public_network
  return_protection     = var.return_protection
  kms_key_tag           = var.kms_key_tag
  auth_type             = var.auth_type
  ip_acl_default_action = var.ip_acl_default_action
  ip_acl                = var.ip_acl

  log {
    audit = var.audit
  }

  dynamic "oidc" {
    for_each = var.oidc == null ? [] : [var.oidc]
    content {
      issuer_url      = oidc.value.issuer_url
      client_id       = oidc.value.client_id
      username_claim  = try(oidc.value.username_claim, null)
      username_prefix = try(oidc.value.username_prefix, null)
      groups_claim    = try(oidc.value.groups_claim, null)
      groups_prefix   = try(oidc.value.groups_prefix, null)
      required_claim  = try(oidc.value.required_claim, null)
    }
  }

  # Only honoured when auth_type is API.
  dynamic "access_entries" {
    for_each = var.access_entries
    content {
      entry  = access_entries.value.entry
      groups = try(access_entries.value.groups, null)

      dynamic "policies" {
        for_each = try(access_entries.value.policies, [])
        content {
          type       = policies.value.type
          scope      = policies.value.scope
          namespaces = try(policies.value.namespaces, null)
        }
      }
    }
  }

  timeouts {
    create = var.cluster_timeouts.create
    update = var.cluster_timeouts.update
    delete = var.cluster_timeouts.delete
  }

  lifecycle {
    # Terraform can't grant the creator admin, so an API cluster without
    # entries is unreachable.
    precondition {
      condition     = var.auth_type != "API" || length(var.access_entries) > 0
      error_message = "auth_type API needs at least one access_entries item."
    }
  }
}

resource "ncloud_nks_node_pool" "this" {
  for_each = local.node_pools

  cluster_uuid   = ncloud_nks_cluster.this.uuid
  node_pool_name = each.value.name
  node_count     = each.value.node_count
  k8s_version    = each.value.version

  # XEN / RHV node pools are sized by product code, KVM ones by spec code.
  product_code     = local.is_kvm ? null : local.node_pool_products[each.key]
  server_spec_code = local.is_kvm ? local.node_pool_products[each.key] : null
  storage_size     = local.is_kvm ? each.value.storage_size : null
  software_code    = local.node_pool_softwares[each.key]

  subnet_no_list = each.value.subnet_no_list
  server_role_id = each.value.server_role_id
  # Regional clusters only.
  zone = var.regional ? each.value.zone : null

  label = each.value.node_labels
  taint = each.value.node_taints

  autoscale {
    enabled = each.value.enable_asg
    min     = each.value.min
    max     = each.value.max
  }

  timeouts {
    create = try(each.value.timeouts.create, null)
    update = try(each.value.timeouts.update, null)
    delete = try(each.value.timeouts.delete, null)
  }
}

# Sub account access for `CONFIG_MAP` auth (`API` uses `access_entries`).
resource "kubernetes_config_map_v1" "this" {
  count = var.auth_type == "CONFIG_MAP" && length(var.ncloud_auth_accounts) > 0 ? 1 : 0

  metadata {
    name      = "ncp-auth"
    namespace = "kube-system"
  }

  data = local.ncloud_auth_configmap_data

  lifecycle {
    ignore_changes = [data, metadata[0].labels, metadata[0].annotations]
  }
}
