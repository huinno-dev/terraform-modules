locals {
  max_subnet_length = max(
  length(var.private_subnets),
  )

  nat_gateway_count = var.single_nat_gateway ? 1 : var.one_nat_gateway_per_az ? length(var.azs) : local.max_subnet_length

  # `subnets` flattened to one entry per CIDR, keyed `<key>-<index>`.
  extra_subnets = merge(concat([{}], [
    for k, s in var.subnets : {
      for i, cidr in s.cidrs : "${k}-${i}" => {
        key   = k
        index = i
        cidr  = cidr
        type  = s.type
        tags  = s.tags
      }
    }
  ])...)

  extra_private_subnet_count = length([for s in local.extra_subnets : s if s.type == "PRIVATE"])
  extra_public_subnet_count  = length([for s in local.extra_subnets : s if s.type == "PUBLIC"])

  # Private subnets get their own route table even without NAT; otherwise they
  # fall back to the VPC main route table and `private_table_routes` is dropped.
  private_route_table_count = (length(var.private_subnets) + local.extra_private_subnet_count) > 0 ? (var.enable_nat_gateway ? max(local.nat_gateway_count, 1) : 1) : 0

  nat_gateway_ips = split(
  ",",
  var.reuse_nat_ips ? join(",", var.external_nat_ip_ids) : join(",", aws_eip.nat.*.id),
  )

  create_vpc = var.vpc_id == "" ? true : false

  enable_flow_log = local.create_vpc && var.enable_flow_log

  create_flow_log_cloudwatch_iam_role  = local.enable_flow_log && var.flow_log_destination_type != "s3" && var.create_flow_log_cloudwatch_iam_role
  create_flow_log_cloudwatch_log_group = local.enable_flow_log && var.flow_log_destination_type != "s3" && var.create_flow_log_cloudwatch_log_group

  flow_log_destination_arn                  = local.create_flow_log_cloudwatch_log_group ? try(aws_cloudwatch_log_group.flow_log[0].arn, null) : var.flow_log_destination_arn
  flow_log_iam_role_arn                     = var.flow_log_destination_type != "s3" && local.create_flow_log_cloudwatch_iam_role ? try(aws_iam_role.vpc_flow_log_cloudwatch[0].arn, null) : var.flow_log_cloudwatch_iam_role_arn
  flow_log_cloudwatch_log_group_name_suffix = var.flow_log_cloudwatch_log_group_name_suffix == "" ? data.aws_vpc.this.id : var.flow_log_cloudwatch_log_group_name_suffix
}