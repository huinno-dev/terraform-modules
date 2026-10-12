resource "aws_eip" "this" {
  for_each = toset(var.azs)

  domain = "vpc"

  tags = merge(
    {
      "Name"            = format("%s-%s", var.name, each.key)
      "elastic-ip-pool" = var.name
    },
    var.tags,
  )
}
