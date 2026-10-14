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
  description = "`XEN` (default), `KVM` or `RHV`. `KVM`: public site, KR region only"
  type        = string
  default     = "XEN"

  validation {
    condition     = contains(["XEN", "KVM", "RHV"], var.hypervisor_code)
    error_message = "hypervisor_code must be one of XEN, KVM or RHV."
  }
}

variable "cluster_type" {
  description = "Control plane size as max nodes: `10`/`50` (XEN/RHV), `250` (KVM)"
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
  description = "Multi-zone (Regional) cluster. Public site only"
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
  description = "`API` or `CONFIG_MAP` (users via the nks-auth module). Only `CONFIG_MAP` to `API` changes in place; otherwise recreates"
  type        = string
  default     = "API"

  validation {
    condition     = contains(["API", "CONFIG_MAP"], var.auth_type)
    error_message = "auth_type must be API or CONFIG_MAP."
  }
}

variable "access_entries" {
  description = "Access entries for `auth_type = API`. Keys: `entry` (required), `groups`, `policies` (`type`, `scope`, `namespaces`)"
  type        = any
  default     = []
}

variable "oidc" {
  description = "OIDC config. Requires `issuer_url`, `client_id`"
  type        = any
  default     = null
}

variable "ip_acl_default_action" {
  description = "Control plane IP ACL default: `allow` or `deny`"
  type        = string
  default     = null
}

variable "ip_acl" {
  description = "Control plane IP ACL entries: `action`, `address`, `comment`"
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

variable "node_pools" {
  description = "Node pools by name. Empty creates a `default` pool from the node pool variables, which are also each pool's defaults"
  type        = any
  default     = {}
}

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
  description = "Node pool zone. Defaults to `az`"
  type        = string
  default     = ""
}

variable "server_image_name" {
  description = "Label of the NKS server image to run on the nodes (i.e.: `ubuntu-22.04`)"
  type        = string
  default     = "ubuntu-22.04"
}

variable "selectors" {
  description = "Node spec filters: `name`, `value` (list), `regex`"
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

variable "node_pool_timeouts" {
  description = "Timeouts applied to the node pool resource"
  type = object({
    create = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default = {}
}
