# Connection values come from the nks module outputs (`cluster_endpoint`,
# `cluster_ca_certificate`, `cluster_uuid`). The account needs cluster admin
# (an `access_entries` item with NKSClusterAdminPolicy on API auth).
provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "ncp-iam-authenticator"
    args        = ["token", "--clusterUuid", var.cluster_uuid, "--region", var.region]
    env         = { NCLOUD_API_GW = var.ncloud_api_gw }
  }
}
