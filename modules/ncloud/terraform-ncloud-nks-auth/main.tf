# Sub account access for an NKS cluster created with `auth_type = CONFIG_MAP`.
resource "kubernetes_config_map_v1" "this" {
  metadata {
    name      = "ncp-auth"
    namespace = "kube-system"
  }

  data = merge(
    {
      mapSubAccounts = yamlencode([for a in var.accounts : {
        subAccountIdNo = a.sub_account_id_no
        username       = a.username
        groups         = a.groups
      }])
    },
    var.authenticate_all ? { authenticateAll = "true" } : {},
  )

  lifecycle {
    # NKS records what it applied in an annotation.
    ignore_changes = [metadata[0].annotations]
  }
}
