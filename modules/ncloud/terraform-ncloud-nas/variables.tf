variable "create" {
  description = "Controls if the NAS volume should be created"
  type        = bool
  default     = true
}

variable "name_postfix" {
  description = "Name of the NAS volume to create, appended to the account prefix. 3-20 characters"
  type        = string
  default     = ""
}

variable "size" {
  description = "NAS volume size in GB. 500 to 10000, in steps of 100"
  type        = number
  default     = null
}

variable "type" {
  description = "Volume allotment protocol type. `NFS` (Linux) or `CIFS` (Windows)"
  type        = string
  default     = "NFS"

  validation {
    condition     = contains(["NFS", "CIFS"], upper(var.type))
    error_message = "type must be either NFS or CIFS."
  }
}

variable "server_instance_no_list" {
  description = "List of server instance numbers to mount the NAS volume on"
  type        = list(string)
  default     = []
}

variable "cifs_user_name" {
  description = "CIFS user name. 6-19 alphanumeric characters. Only used when `type` is CIFS"
  type        = string
  default     = null
}

variable "cifs_user_password" {
  description = "CIFS user password. 8-14 characters. Only used when `type` is CIFS"
  type        = string
  default     = null
  sensitive   = true
}

variable "description" {
  description = "NAS volume description. 1-1000 characters"
  type        = string
  default     = null
}

variable "zone" {
  description = "Zone code the NAS volume is created in. Defaults to the first zone of the region"
  type        = string
  default     = null
}

variable "return_protection" {
  description = "Termination protection status"
  type        = bool
  default     = false
}

variable "is_encrypted_volume" {
  description = "Volume encryption. Cannot be changed after creation"
  type        = bool
  default     = false
}

variable "timeouts" {
  description = "Timeouts applied to the NAS volume resource"
  type = object({
    create = optional(string)
    delete = optional(string)
  })
  default = {}
}
