locals {
  create_vpc = var.vpc_id == "" ? true : false

  max_subnet_length = max(
    length(var.private_subnets),
    length(var.lb_subnets),
  )

  # NAT gateway is only provisioned when explicitly enabled. Without it the
  # count collapses to 0 so no NAT gateway / route is created.
  nat_gateway_count = var.enable_nat_gateway ? (
    var.single_nat_gateway ? 1 : var.one_nat_gateway_per_az ? length(var.azs) : local.max_subnet_length
  ) : 0

  # Private / LB subnets still need a route table even when NAT is disabled,
  # otherwise they stay attached to the VPC default route table.
  private_route_table_count = (length(var.private_subnets) + length(var.lb_subnets)) > 0 ? max(local.nat_gateway_count, 1) : 0
}
