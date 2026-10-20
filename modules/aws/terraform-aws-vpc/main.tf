################################################################################
# VPC
################################################################################

resource "aws_vpc" "this" {
  count = local.create_vpc ? 1 : 0

  cidr_block = var.cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  assign_generated_ipv6_cidr_block = var.enable_ipv6

  tags = merge(
  {
    "Name" = format("%s", var.name)
  },
  var.tags,
  var.vpc_tags,
  )
}

resource "aws_vpc_ipv4_cidr_block_association" "this" {
  count = length(var.secondary_cidr_blocks) > 0 ? length(var.secondary_cidr_blocks) : 0

  vpc_id = data.aws_vpc.this.id

  cidr_block = element(var.secondary_cidr_blocks, count.index)
}


################################################################################
# Internet Gateway
################################################################################

resource "aws_internet_gateway" "this" {
  count = local.create_vpc ? 1 : 0

  vpc_id = data.aws_vpc.this.id

  tags = merge(
  {
    "Name" = format("%s", var.name)
  },
  var.tags,
  var.igw_tags,
  )
}

resource "aws_egress_only_internet_gateway" "this" {
  count = local.create_vpc != true && var.create_egress_only_igw && var.enable_ipv6 && local.max_subnet_length > 0 ? 1 : 0

  vpc_id = data.aws_vpc.this.id

  tags = merge(
  {
    "Name" = format("%s", var.name)
  },
  var.tags,
  var.igw_tags,
  )
}


################################################################################
# Public subnet
################################################################################

resource "aws_subnet" "public" {
  count = length(var.public_subnets) > 0 && (false == var.one_nat_gateway_per_az || length(var.public_subnets) >= length(var.azs)) ? length(var.public_subnets) : 0

  vpc_id = data.aws_vpc.this.id
  cidr_block = element(concat(var.public_subnets, [
    ""]), count.index)
  availability_zone = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) > 0 ? element(var.azs, count.index) : null
  availability_zone_id = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) == 0 ? element(var.azs, count.index) : null
  map_public_ip_on_launch = var.map_public_ip_on_launch
  assign_ipv6_address_on_creation = var.public_subnet_assign_ipv6_address_on_creation == null ? var.assign_ipv6_address_on_creation : var.public_subnet_assign_ipv6_address_on_creation

  ipv6_cidr_block = var.enable_ipv6 && length(var.public_subnet_ipv6_prefixes) > 0 ? cidrsubnet(data.aws_vpc.this.ipv6_cidr_block, 8, var.public_subnet_ipv6_prefixes[count.index]) : null

  tags = merge(
  {
    "Name" = format(
    "%s-${var.public_subnet_suffix}-%s",
    var.name,
    element(var.azs, count.index),
    )
  },
  var.tags,
  var.public_subnet_tags,
  )
}

resource "aws_route_table" "public" {
  count = length(var.public_subnets) > 0 || local.extra_public_subnet_count > 0 ? 1 : 0

  vpc_id = data.aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.vpc_id == "" ? aws_internet_gateway.this[0].id : data.aws_internet_gateway.this[0].id
  }

  dynamic "route" {
    for_each = var.public_table_routes
    content {
      cidr_block      = route.value.cidr_block
      ipv6_cidr_block = lookup(route.value, "ipv6_cidr_block", null)

      # One of the following targets must be provided
      egress_only_gateway_id    = lookup(route.value, "egress_only_gateway_id", null)
      gateway_id                = lookup(route.value, "gateway_id", null)
      nat_gateway_id            = lookup(route.value, "nat_gateway_id", null)
      network_interface_id      = lookup(route.value, "network_interface_id", null)
      transit_gateway_id        = lookup(route.value, "transit_gateway_id", null)
      vpc_endpoint_id           = lookup(route.value, "vpc_endpoint_id", null)
      vpc_peering_connection_id = lookup(route.value, "vpc_peering_connection_id", null)
    }
  }

  tags = merge(
  {
    "Name" = format("%s-${var.public_subnet_suffix}", var.name)
  },
  var.tags,
  var.public_route_table_tags,
  )
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnets) > 0 ? length(var.public_subnets) : 0

  subnet_id = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public[0].id
}


################################################################################
# Private subnet
################################################################################

resource "aws_subnet" "private" {
  count = length(var.private_subnets) > 0 ? length(var.private_subnets) : 0

  vpc_id = data.aws_vpc.this.id
  cidr_block = var.private_subnets[count.index]
  availability_zone = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) > 0 ? element(var.azs, count.index) : null
  availability_zone_id = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) == 0 ? element(var.azs, count.index) : null
  assign_ipv6_address_on_creation = var.private_subnet_assign_ipv6_address_on_creation == null ? var.assign_ipv6_address_on_creation : var.private_subnet_assign_ipv6_address_on_creation

  ipv6_cidr_block = var.enable_ipv6 && length(var.private_subnet_ipv6_prefixes) > 0 ? cidrsubnet(data.aws_vpc.this.ipv6_cidr_block, 8, var.private_subnet_ipv6_prefixes[count.index]) : null

  tags = merge(
  {
    "Name" = format(
    "%s-${var.private_subnet_suffix}-%s",
    var.name,
    element(var.azs, count.index),
    )
  },
  var.tags,
  var.private_subnet_tags,
  )
}

resource "aws_eip" "nat" {
  count = var.enable_nat_gateway && false == var.reuse_nat_ips && false == var.private_nat_gateway ? local.nat_gateway_count : 0

  domain = "vpc"

  tags = merge(
  {
    "Name" = format(
    "%s-%s",
    var.name,
    element(var.azs, var.single_nat_gateway ? 0 : count.index),
    )
  },
  var.tags,
  var.nat_eip_tags,
  )
}

resource "aws_nat_gateway" "this" {
  count = var.enable_nat_gateway ? local.nat_gateway_count : 0

  allocation_id = var.private_nat_gateway == false ? element(
  local.nat_gateway_ips,
  var.single_nat_gateway ? 0 : count.index,
  ) : ""

  connectivity_type = var.private_nat_gateway == false ? "public" : "private"

  subnet_id = length(var.public_subnets) > 0 ? element(
  aws_subnet.public.*.id, var.single_nat_gateway ? 0 : count.index
  ) : var.public_subnet_ids[var.single_nat_gateway ? 0 : count.index]

  tags = merge(
  {
    "Name" = format(
    "%s-%s",
    var.name,
    element(var.azs, var.single_nat_gateway ? 0 : count.index),
    )
  },
  var.tags,
  var.nat_gateway_tags,
  )
}

resource "aws_route_table" "private" {
  count = local.private_route_table_count

  vpc_id = data.aws_vpc.this.id

  # Kept inline (not aws_route) because `private_table_routes` is inline too;
  # mixing the two makes them overwrite each other.
  dynamic "route" {
    # try(): with only `subnets` private entries there can be a route table
    # but no NAT gateway (nat_gateway_count follows `private_subnets`).
    for_each = var.enable_nat_gateway ? try([aws_nat_gateway.this[count.index].id], []) : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = route.value
    }
  }

  dynamic "route" {
    for_each = var.private_table_routes
    content {
      cidr_block      = route.value.cidr_block
      ipv6_cidr_block = lookup(route.value, "ipv6_cidr_block", null)

      # One of the following targets must be provided
      egress_only_gateway_id    = lookup(route.value, "egress_only_gateway_id", null)
      gateway_id                = lookup(route.value, "gateway_id", null)
      nat_gateway_id            = lookup(route.value, "nat_gateway_id", null)
      network_interface_id      = lookup(route.value, "network_interface_id", null)
      transit_gateway_id        = lookup(route.value, "transit_gateway_id", null)
      vpc_endpoint_id           = lookup(route.value, "vpc_endpoint_id", null)
      vpc_peering_connection_id = lookup(route.value, "vpc_peering_connection_id", null)
    }
  }

  tags = merge(
  {
    "Name" = var.single_nat_gateway || !var.enable_nat_gateway ? "${var.name}-${var.private_subnet_suffix}" : format(
    "%s-${var.private_subnet_suffix}-%s",
    var.name,
    element(var.azs, count.index),
    )
  },
  var.tags,
  var.private_route_table_tags,
  )
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnets)

  subnet_id = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(
  aws_route_table.private.*.id,
  var.single_nat_gateway || !var.enable_nat_gateway ? 0 : count.index,
  )
}


################################################################################
# Additional subnets (`subnets`), attached to the module's public or private
# route table by type.
################################################################################

resource "aws_subnet" "extra" {
  for_each = local.extra_subnets

  vpc_id                  = data.aws_vpc.this.id
  cidr_block              = each.value.cidr
  availability_zone       = length(regexall("^[a-z]{2}-", element(var.azs, each.value.index))) > 0 ? element(var.azs, each.value.index) : null
  availability_zone_id    = length(regexall("^[a-z]{2}-", element(var.azs, each.value.index))) == 0 ? element(var.azs, each.value.index) : null
  map_public_ip_on_launch = each.value.type == "PUBLIC" ? var.map_public_ip_on_launch : false

  tags = merge(
    {
      "Name" = format("%s-%s-%s", var.name, each.value.key, element(var.azs, each.value.index))
    },
    var.tags,
    each.value.tags,
  )
}

resource "aws_route_table_association" "extra" {
  for_each = local.extra_subnets

  subnet_id = aws_subnet.extra[each.key].id
  # element() wraps, so private entries spread over per-AZ route tables the
  # same way `private_subnets` do.
  route_table_id = each.value.type == "PUBLIC" ? aws_route_table.public[0].id : element(
    aws_route_table.private.*.id,
    var.single_nat_gateway || !var.enable_nat_gateway ? 0 : each.value.index,
  )
}
