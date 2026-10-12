variable "root_domain" {
  type = string
}

data "aws_route53_zone" "this" {
  name = var.root_domain
}

data "aws_caller_identity" "current" {}

output "zone_id" {
  value = data.aws_route53_zone.this.id
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "caller_arn" {
  value = data.aws_caller_identity.current.arn
}

output "caller_user" {
  value = data.aws_caller_identity.current.user_id
}

output "caller_name" {
  value = split("/", data.aws_caller_identity.current.arn)[1]
}