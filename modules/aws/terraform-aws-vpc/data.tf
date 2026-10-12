data "aws_vpc" "this" {
  id = var.vpc_id == "" ? aws_vpc.this.0.id : var.vpc_id
}

data "aws_internet_gateway" "this" {
  count = var.vpc_id == "" ? 0 : 1
  filter {
    name   = "attachment.vpc-id"
    values = [var.vpc_id == "" ? aws_vpc.this.0.id : var.vpc_id]
  }
}

#data "aws_nat_gateway" "default" {
#  count = local.max_subnet_length > 0 ? local.nat_gateway_count : 0
#  subnet_id = length(var.public_subnets) > 0 ? element(aws_subnet.public.*.id, count.index) : var.public_subnet_ids[count.index]
#  state = "available"
#  tags = {
#    "Name" = format(
#    "%s-%s",
#    var.name,
#    element(var.azs, var.single_nat_gateway ? 0 : count.index),
#    )
#  }
#}

data "aws_subnets" "public" {
  filter {
    name   = "subnet-id"
    values = var.public_subnet_ids
  }
}

data "aws_subnet" "public" {
  for_each = toset(data.aws_subnets.public.ids)
  id       = each.value
}