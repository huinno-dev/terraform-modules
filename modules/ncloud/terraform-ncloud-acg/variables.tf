variable "acg_id" {
  description = "The Access Control Group ID. When set, rules are attached to that existing ACG instead of creating one"
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "The VPC ID the ACG belongs to. Required when creating an ACG"
  type        = string
  default     = ""
}

variable "name" {
  description = "Name of the access control group"
  type        = string
  default     = ""
}

variable "description" {
  description = "Description of a access control group"
  type        = string
  default     = ""
}

variable "create_rules" {
  description = "Controls whether the ACG rule set is managed by this module"
  type        = bool
  default     = true
}

variable "inbound_rules" {
  description = "List of inbound (ingress) rules. Each entry supports `protocol` (required) and one of `ip_block` / `source_access_control_group_no`, plus optional `port_range` and `description`."
  type        = any
  default     = []
}

variable "outbound_rules" {
  description = "List of outbound (egress) rules. Same shape as `inbound_rules`."
  type        = any
  default     = []
}

variable "timeouts" {
  description = "Timeouts applied to the ACG rule resource"
  type = object({
    create = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default = {}
}
