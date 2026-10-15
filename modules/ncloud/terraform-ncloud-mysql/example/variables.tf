variable "region" {
}

variable "site" {
}

variable "ncloud_access_key" {
  default = ""
}

variable "ncloud_secret_key" {
  default = ""
}

variable "mysql_admin_password" {
  type      = string
  sensitive = true
}

variable "mysql_app_password" {
  type      = string
  sensitive = true
}
