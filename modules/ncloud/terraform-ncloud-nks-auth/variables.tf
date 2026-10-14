variable "accounts" {
  description = "Sub accounts mapped in `ncp-auth`. `sub_account_id_no` is the ID shown on the Sub Account detail page"
  type = list(object({
    sub_account_id_no = string
    username          = string
    groups            = optional(list(string), [])
  }))
  default = []
}

variable "authenticate_all" {
  description = "Authenticate every sub account; permissions still come from RBAC"
  type        = bool
  default     = false
}
