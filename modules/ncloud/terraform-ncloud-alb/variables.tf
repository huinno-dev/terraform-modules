variable "create_lb" {
  description = "Controls if the Load Balancer should be created"
  type        = bool
  default     = true
}

variable "name" {
  description = "Name of a load balancer instance"
  type        = string
  default     = null
}

variable "description" {
  description = "Description of a load balancer instance"
  type        = string
  default     = null
}

variable "network_type" {
  description = "The network type of load balancer to create. `PUBLIC` (default) or `PRIVATE`"
  type        = string
  default     = null
}

variable "idle_timeout" {
  description = "The time in seconds that the idle timeout. Only valid when `type` is not `NETWORK`. Default: 60"
  type        = number
  default     = null
}

variable "type" {
  description = "The type of load balancer to create. `APPLICATION`, `NETWORK` or `NETWORK_PROXY`"
  type        = string
  default     = null
}

variable "throughput_type" {
  description = "The performance type code of load balancer. `SMALL` | `MEDIUM` | `LARGE` | `XLARGE` for `APPLICATION` / `NETWORK_PROXY`, `DYNAMIC` for `NETWORK`"
  type        = string
  default     = null
}

variable "subnet_no_list" {
  description = "A list of IDs in the associated Subnets"
  type        = list(string)
  default     = []
}

variable "vpc_no" {
  description = "The ID of the VPC the target groups are created in. Used when a target group entry does not carry its own `vpc_no`"
  type        = string
  default     = null
}

variable "target_groups" {
  description = <<-EOT
    A list of maps defining the target groups to create. Supported keys:
    `name`, `port`, `protocol` (required), `description`, `vpc_no`, `target_type`,
    `algorithm_type`, `use_sticky_session`, `use_proxy_protocol`,
    `target_no_list` (server instance numbers to attach), and `health_check`
    (`protocol` required, plus `port`, `http_method`, `url_path`, `cycle`,
    `up_threshold`, `down_threshold`).
  EOT
  type        = any
  default     = []
}

variable "listeners" {
  description = <<-EOT
    A map of listeners for this load balancer, keyed by an arbitrary name.
    Each entry requires `target_group_index` (index into `target_groups`),
    `port` and `protocol`, and optionally `tls_min_version_type`, `use_http2`
    and `ssl_certificate_no`.
  EOT
  type        = any
  default     = {}
}
