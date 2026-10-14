variable "cluster_uuid" {
  type = string
}

variable "cluster_endpoint" {
  type = string
}

variable "cluster_ca_certificate" {
  type      = string
  sensitive = true
}

variable "region" {
  type    = string
  default = "KR"
}

variable "ncloud_api_gw" {
  description = "Public: https://ncloud.apigw.ntruss.com, gov: https://ncloud.apigw.gov-ntruss.com"
  type        = string
  default     = "https://ncloud.apigw.ntruss.com"
}
