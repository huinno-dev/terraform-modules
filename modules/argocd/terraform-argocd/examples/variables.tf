variable "defaults" {
  description = "Map of default values which will be used for each item."
  type        = any
  default     = {}
}

variable "repos" {
  type    = any
  default = {}
}

variable "projects" {
  type    = any
  default = {}
}

variable "apps" {
  type    = any
  default = {}
}

variable "argocd_username" {
  type    = string
  default = "admin"
}

variable "argocd_password" {
  type      = string
  default   = ""
  sensitive = true
}
