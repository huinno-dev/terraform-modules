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

  # `zone` must be omitted for a multi-zone (Regional) cluster.
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
}

resource "ncloud_nks_node_pool" "this" {
  cluster_uuid   = ncloud_nks_cluster.this.uuid
  node_pool_name = var.node_pool_name != "" ? var.node_pool_name : var.name
  node_count     = var.node_count
  k8s_version    = var.node_pool_version

  # XEN / RHV node pools are sized by product code, KVM ones by spec code.
  product_code     = local.is_kvm ? null : local.node_pool_product
  server_spec_code = local.is_kvm ? local.node_pool_product : null
  storage_size     = local.is_kvm ? var.storage_size : null
  software_code    = local.node_pool_software

  subnet_no_list = local.node_pool_subnet_no_list
  server_role_id = var.server_role_id
  # Required only for a node pool inside a multi-zone (Regional) cluster.
  zone = var.regional ? local.node_pool_zone : null

  label = var.node_labels
  taint = var.node_taints

  autoscale {
    enabled = var.enable_asg
    min     = var.min
    max     = var.max
  }

  timeouts {
    create = var.node_pool_timeouts.create
    update = var.node_pool_timeouts.update
    delete = var.node_pool_timeouts.delete
  }
}

# Sub account authorisation through the ncp-auth ConfigMap. Clusters using
# `auth_type = "API"` use `access_entries` on the cluster instead.
resource "kubernetes_config_map_v1" "this" {
  count = length(var.ncloud_auth_accounts) > 0 ? 1 : 0

  metadata {
    name      = "ncp-auth"
    namespace = "kube-system"
  }

  data = local.ncloud_auth_configmap_data

  lifecycle {
    ignore_changes = [data, metadata[0].labels, metadata[0].annotations]
  }
}
