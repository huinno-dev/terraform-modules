output "cluster_id" {
  description = "The ID of the NKS cluster"
  value       = ncloud_nks_cluster.this.id
}

output "cluster_uuid" {
  description = "The UUID of the NKS cluster (same value as `cluster_id`)"
  value       = ncloud_nks_cluster.this.uuid
}

output "cluster_endpoint" {
  description = "Control plane API address"
  value       = ncloud_nks_cluster.this.endpoint
}

output "cluster_name" {
  description = "The name of the NKS cluster"
  value       = ncloud_nks_cluster.this.name
}

output "cluster_version" {
  description = "Kubernetes version running on the cluster"
  value       = ncloud_nks_cluster.this.k8s_version
}

output "cluster_acg" {
  description = "The ID of the ACG created for the cluster"
  value       = ncloud_nks_cluster.this.acg_no
}

output "cluster_ca_certificate" {
  description = "Cluster CA certificate, base64 encoded"
  value       = data.ncloud_nks_kube_config.this.cluster_ca_certificate
  sensitive   = true
}

output "cluster_client_certificate" {
  description = "Client certificate for the cluster, base64 encoded"
  value       = data.ncloud_nks_kube_config.this.client_certificate
  sensitive   = true
}

output "cluster_client_key" {
  description = "Client key for the cluster, base64 encoded"
  value       = data.ncloud_nks_kube_config.this.client_key
  sensitive   = true
}

output "cluster_host" {
  description = "Cluster host from the kube config"
  value       = data.ncloud_nks_kube_config.this.host
}

output "node_pools" {
  description = "Node pools by key"
  value = {
    for k, p in ncloud_nks_node_pool.this : k => {
      id            = p.id
      name          = p.node_pool_name
      instance_no   = p.instance_no
      nodes         = p.nodes
      product_code  = local.node_pool_products[k]
      software_code = local.node_pool_softwares[k]
    }
  }
}

# `default` pool only; null when `node_pools` is set.

output "node_pool_id" {
  description = "Node pool ID (`cluster_uuid:node_pool_name`)"
  value       = try(ncloud_nks_node_pool.this["default"].id, null)
}

output "node_pool_instance_no" {
  description = "Node pool instance number"
  value       = try(ncloud_nks_node_pool.this["default"].instance_no, null)
}

output "node_pool_nodes" {
  description = "Running nodes"
  value       = try(ncloud_nks_node_pool.this["default"].nodes, null)
}

output "node_pool_product_code" {
  description = "Product code (XEN/RHV) or spec code (KVM)"
  value       = try(local.node_pool_products["default"], null)
}

output "node_pool_software_code" {
  description = "Server image code"
  value       = try(local.node_pool_softwares["default"], null)
}
