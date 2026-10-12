# variable

variable "name" {
  description = "Name to be used on all resources as prefix"
  default     = ""
}

variable "azs" {
  description = "List of availability zones to allocate an EIP in. One EIP per AZ."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags for the EIPs"
  type        = map(string)
  default     = {}
}
