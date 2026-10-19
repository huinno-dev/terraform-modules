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

variable "redis_password" {
  type      = string
  sensitive = true
}
