variable "name" {
  description = "NKS cluster name"
  type        = string
  default     = ""
}

variable "cluster_version" {
  description = "Kubernetes `<major>.<minor>` version to use for the NKS cluster (i.e.: `1.31`)"
  type        = string
  default     = null
}

variable "hypervisor_code" {
  description = "Hypervisor code. `XEN` (default), `KVM` or `RHV`. `KVM` is only available on the public site in the KR region"
  type        = string
  default     = "XEN"

  validation {
    condition     = contains(["XEN", "KVM", "RHV"], var.hypervisor_code)
    error_message = "hypervisor_code must be one of XEN, KVM or RHV."
  }
}

variable "cluster_type" {
  description = "Control plane sizing, expressed as the maximum node count. `10` or `50` for XEN/RHV, `250` for KVM"
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "The VPC Id"
  type        = string
  default     = ""
}

variable "az" {
  description = "Availability zone the cluster is placed in. Ignored when `regional` is true"
  type        = string
  default     = ""
}

variable "regional" {
  description = "Create a multi-zone (Regional) cluster. Only supported on the public site, and only for Kubernetes versions that support it"
  type        = bool
  default     = false
}

variable "key_name" {
  description = "Login key name used for the worker nodes"
  type        = string
  default     = ""
}

variable "network_plugin" {
  description = "Kubernetes network plugin. Only `cilium` is supported"
  type        = string
  default     = "cilium"
}

variable "private_subnet_id" {
  description = "Private subnet Id for the cluster. Ignored when `subnet_no_list` is set"
  type        = string
  default     = ""
}

variable "subnet_no_list" {
  description = "List of subnet Ids for the cluster. Takes precedence over `private_subnet_id`"
  type        = list(string)
  default     = []
}

variable "lb_subnet_id" {
  description = "Subnet Id reserved for the private load balancer"
  type        = string
  default     = ""
}

variable "public_lb_subnet_id" {
  description = "Subnet Id reserved for the public load balancer. Required on the public and gov sites"
  type        = string
  default     = null
}

variable "public_network" {
  description = "Whether the cluster uses a public subnet network"
  type        = bool
  default     = null
}

variable "return_protection" {
  description = "Protect the cluster from being returned (deleted)"
  type        = bool
  default     = null
}

variable "kms_key_tag" {
  description = "KMS key tag used for cluster secret encryption"
  type        = string
  default     = null
}

variable "audit" {
  description = "Enable the audit log"
  type        = bool
  default     = true
}

variable "auth_type" {
  description = "Authentication type for the cluster. `API` or `CONFIG_MAP`. Changing from `CONFIG_MAP` to `API` is allowed in place, any other change recreates the cluster"
  type        = string
  default     = null
}

variable "access_entries" {
  description = <<-EOT
    Access entries for cluster access management. Only honoured when
    `auth_type` is `API`. Each entry supports `entry` (NRN, required),
    `groups`, and `policies` (`type` and `scope` required, `namespaces`
    optional).
  EOT
  type        = any
  default     = []
}

variable "oidc" {
  description = "OIDC configuration. Supports `issuer_url` and `client_id` (required) plus `username_claim`, `username_prefix`, `groups_claim`, `groups_prefix` and `required_claim`"
  type        = any
  default     = null
}

variable "ip_acl_default_action" {
  description = "Default action of the control plane IP ACL. `allow` or `deny`. Supported on the public and gov sites"
  type        = string
  default     = null
}

variable "ip_acl" {
  description = "Control plane IP ACL entries. Each entry supports `action` and `address` (required) and `comment`"
  type = set(object({
    action  = string
    address = string
    comment = optional(string, "")
  }))
  default = null
}

variable "cluster_timeouts" {
  description = "Timeouts applied to the cluster resource"
  type = object({
    create = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default = {}
}

# Node pool

variable "node_pool_name" {
  description = "Node pool name. Defaults to `name`"
  type        = string
  default     = ""
}

variable "node_pool_version" {
  description = "Kubernetes version of the node pool. Only upgrades are supported"
  type        = string
  default     = null
}

variable "node_pool_subnet_no_list" {
  description = "List of subnet Ids the node pool places nodes in. Defaults to the cluster subnets"
  type        = list(string)
  default     = []
}

variable "node_pool_zone" {
  description = "Zone the node pool is placed in. Defaults to `az`. Required for a node pool of a multi-zone (Regional) cluster"
  type        = string
  default     = ""
}

variable "server_image_name" {
  description = "Label of the NKS server image to run on the nodes (i.e.: `ubuntu-22.04`)"
  type        = string
  default     = "ubuntu-22.04"
}

variable "selectors" {
  description = "Filters narrowing down the `ncloud_nks_server_products` lookup. Each entry supports `name`, `value` (list) and `regex`"
  type        = any
  default     = {}
}

variable "storage_size" {
  description = "Default storage size in GB for a KVM node pool. Ignored for XEN/RHV"
  type        = number
  default     = null
}

variable "server_role_id" {
  description = "SubAccount server role Id assigned to the nodes"
  type        = string
  default     = null
}

variable "node_count" {
  description = "Number of nodes. Required when autoscaling is disabled"
  type        = number
  default     = 1
}

variable "enable_asg" {
  description = "Enable node pool autoscaling"
  type        = bool
  default     = false
}

variable "min" {
  description = "Minimum number of nodes when autoscaling is enabled"
  type        = number
  default     = 1
}

variable "max" {
  description = "Maximum number of nodes when autoscaling is enabled"
  type        = number
  default     = 1
}

variable "node_labels" {
  description = "Labels applied to the node pool. Each entry requires `key` and `value`"
  type = set(object({
    key   = string
    value = string
  }))
  default = null
}

variable "node_taints" {
  description = "Taints applied to the node pool. Each entry requires `key`, `value` and `effect`"
  type = set(object({
    key    = string
    value  = string
    effect = string
  }))
  default = null
}

variable "node_pool_timeouts" {
  description = "Timeouts applied to the node pool resource"
  type = object({
    create = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default = {}
}

variable "ncloud_auth_accounts" {
  description = "List of account maps to add to the `ncp-auth` ConfigMap. Only used when the cluster authenticates through `CONFIG_MAP`"
  type        = list(any)
  default     = []
}
