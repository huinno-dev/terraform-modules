variable "vpc_id" {
  description = "The VPC ID. When set, an existing VPC is used instead of creating one"
  type        = string
  default     = ""
}

variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = ""
}

variable "cidr" {
  description = "The CIDR block for the VPC. Must be inside the private ranges (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16)"
  type        = string
  default     = "0.0.0.0/0"
}

variable "azs" {
  description = "A list of availability zones names or ids in the region"
  type        = list(string)
  default     = []
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "public_subnet_suffix" {
  description = "Suffix to append to public subnets name"
  type        = string
  default     = "public"
}

variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "private_subnet_suffix" {
  description = "Suffix to append to private subnets name"
  type        = string
  default     = "private"
}

variable "enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
  type        = bool
  default     = false
}

variable "single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  type        = bool
  default     = false
}

variable "one_nat_gateway_per_az" {
  description = "Should be true if you want only one NAT Gateway per availability zone. Requires `var.azs` to be set, and the number of `public_subnets` created to be greater than or equal to the number of availability zones specified in `var.azs`."
  type        = bool
  default     = false
}

variable "nat_subnets" {
  description = "A list of subnets dedicated to the NAT Gateways. Ncloud requires the NAT Gateway to sit in a PUBLIC subnet whose usage type is `NATGW`. One entry per NAT Gateway is required when `enable_nat_gateway` is true."
  type        = list(string)
  default     = []
}

variable "nat_subnet_suffix" {
  description = "Suffix to append to NAT Gateway subnets name"
  type        = string
  default     = "nat"
}

variable "lb_subnets" {
  description = "A list of private load balancer subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "lb_subnet_suffix" {
  description = "Suffix to append to private load balancer subnets name"
  type        = string
  default     = "lb"
}

variable "public_lb_subnets" {
  description = "A list of public load balancer subnets inside the VPC. NKS requires one (`lb_public_subnet_no`) on the public and gov sites."
  type        = list(string)
  default     = []
}

variable "public_lb_subnet_suffix" {
  description = "Suffix to append to public load balancer subnets name"
  type        = string
  default     = "public-lb"
}

variable "network_acl_inbound_rules" {
  description = "A list of inbound rules applied to the Network ACL created by this module. Each entry supports `priority`, `protocol`, `rule_action`, and optionally `ip_block`, `deny_allow_group_no`, `port_range`, `description`."
  type        = any
  default     = []
}

variable "network_acl_outbound_rules" {
  description = "A list of outbound rules applied to the Network ACL created by this module. Same shape as `network_acl_inbound_rules`."
  type        = any
  default     = []
}

variable "subnets" {
  description = "Additional subnets by purpose (e.g. `db`). `cidrs` are placed in `azs` order and named `<name>-<key>-<index>`. `type` is PRIVATE (default) or PUBLIC, `usage` is GEN (default) or LOADB; they share the module's route tables and Network ACL"
  type = map(object({
    cidrs = list(string)
    type  = optional(string, "PRIVATE")
    usage = optional(string, "GEN")
  }))
  default = {}

  validation {
    condition     = alltrue([for k, s in var.subnets : contains(["PRIVATE", "PUBLIC"], s.type) && contains(["GEN", "LOADB"], s.usage)])
    error_message = "subnets[*].type must be PRIVATE or PUBLIC, and usage GEN or LOADB."
  }

  validation {
    condition     = alltrue([for k in keys(var.subnets) : can(regex("^[a-z][a-z0-9-]*$", k))])
    error_message = "subnets keys become part of the subnet name: lowercase letters, digits and -, starting with a letter."
  }
}
