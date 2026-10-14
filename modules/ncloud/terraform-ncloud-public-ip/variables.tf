variable "public_ips" {
  description = "Public IPs by name. Optional per entry: `description`, `server_instance_no` (server to attach on creation)"
  type = map(object({
    description        = optional(string)
    server_instance_no = optional(string)
  }))
  default = {}
}
