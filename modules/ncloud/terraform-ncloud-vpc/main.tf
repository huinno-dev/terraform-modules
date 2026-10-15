resource "ncloud_vpc" "this" {
  count = local.create_vpc ? 1 : 0

  name            = var.name
  ipv4_cidr_block = var.cidr
}

resource "ncloud_network_acl" "this" {
  vpc_no      = data.ncloud_vpc.this.id
  name        = "${var.name}-acl"
  description = "Network ACL for ${var.name}"
}

resource "ncloud_network_acl_rule" "this" {
  count = length(var.network_acl_inbound_rules) > 0 || length(var.network_acl_outbound_rules) > 0 ? 1 : 0

  network_acl_no = ncloud_network_acl.this.id

  dynamic "inbound" {
    for_each = var.network_acl_inbound_rules
    content {
      priority            = inbound.value.priority
      protocol            = inbound.value.protocol
      rule_action         = inbound.value.rule_action
      ip_block            = try(inbound.value.ip_block, null)
      deny_allow_group_no = try(inbound.value.deny_allow_group_no, null)
      port_range          = try(inbound.value.port_range, null)
      description         = try(inbound.value.description, null)
    }
  }

  dynamic "outbound" {
    for_each = var.network_acl_outbound_rules
    content {
      priority            = outbound.value.priority
      protocol            = outbound.value.protocol
      rule_action         = outbound.value.rule_action
      ip_block            = try(outbound.value.ip_block, null)
      deny_allow_group_no = try(outbound.value.deny_allow_group_no, null)
      port_range          = try(outbound.value.port_range, null)
      description         = try(outbound.value.description, null)
    }
  }
}

# Public subnet

resource "ncloud_subnet" "public" {
  count = length(var.public_subnets)

  name           = "${var.name}-${var.public_subnet_suffix}-${count.index}"
  vpc_no         = data.ncloud_vpc.this.id
  subnet         = var.public_subnets[count.index]
  zone           = element(var.azs, count.index)
  network_acl_no = ncloud_network_acl.this.id
  subnet_type    = "PUBLIC"
  usage_type     = "GEN"
}

resource "ncloud_route_table" "public" {
  count = length(var.public_subnets) > 0 || length(var.public_lb_subnets) > 0 || local.nat_gateway_count > 0 || local.extra_public_subnet_count > 0 ? 1 : 0

  vpc_no                = data.ncloud_vpc.this.id
  supported_subnet_type = "PUBLIC"
  name                  = "${var.name}-${var.public_subnet_suffix}"
  description           = "Route table for ${var.public_subnet_suffix}"
}

resource "ncloud_route_table_association" "public" {
  count = length(var.public_subnets)

  route_table_no = ncloud_route_table.public[0].id
  subnet_no      = ncloud_subnet.public[count.index].id
}

# Private subnet

resource "ncloud_subnet" "private" {
  count = length(var.private_subnets)

  name           = "${var.name}-${var.private_subnet_suffix}-${count.index}"
  vpc_no         = data.ncloud_vpc.this.id
  subnet         = var.private_subnets[count.index]
  zone           = element(var.azs, count.index)
  network_acl_no = ncloud_network_acl.this.id
  subnet_type    = "PRIVATE"
  usage_type     = "GEN"
}

resource "ncloud_route_table" "private" {
  count = local.private_route_table_count

  vpc_no                = data.ncloud_vpc.this.id
  supported_subnet_type = "PRIVATE"
  name                  = local.private_route_table_count > 1 ? "${var.name}-${var.private_subnet_suffix}-${count.index}" : "${var.name}-${var.private_subnet_suffix}"
  description           = "Route table for ${var.private_subnet_suffix}"
}

resource "ncloud_route_table_association" "private" {
  count = length(var.private_subnets)

  route_table_no = ncloud_route_table.private[count.index % local.private_route_table_count].id
  subnet_no      = ncloud_subnet.private[count.index].id
}

# NAT gateway
#
# A NAT gateway has to sit in a dedicated subnet whose usage_type is NATGW, and
# it allocates its own public IP - no separate ncloud_public_ip is needed.

resource "ncloud_subnet" "nat" {
  count = local.nat_gateway_count > 0 ? length(var.nat_subnets) : 0

  name           = "${var.name}-${var.nat_subnet_suffix}-${count.index}"
  vpc_no         = data.ncloud_vpc.this.id
  subnet         = var.nat_subnets[count.index]
  zone           = element(var.azs, count.index)
  network_acl_no = ncloud_network_acl.this.id
  subnet_type    = "PUBLIC"
  usage_type     = "NATGW"
}

resource "ncloud_nat_gateway" "this" {
  count = local.nat_gateway_count

  vpc_no      = data.ncloud_vpc.this.id
  zone        = element(var.azs, count.index)
  subnet_no   = ncloud_subnet.nat[count.index].id
  name        = "${var.name}-${count.index}"
  description = "NAT gateway for ${var.name}"
}

resource "ncloud_route" "private" {
  count = local.nat_gateway_count

  route_table_no         = ncloud_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  target_type            = "NATGW"
  target_name            = ncloud_nat_gateway.this[count.index].name
  target_no              = ncloud_nat_gateway.this[count.index].id
}

# Load balancer subnet

resource "ncloud_subnet" "lb" {
  count = length(var.lb_subnets)

  name           = "${var.name}-${var.lb_subnet_suffix}-${count.index}"
  vpc_no         = data.ncloud_vpc.this.id
  subnet         = var.lb_subnets[count.index]
  zone           = element(var.azs, count.index)
  network_acl_no = ncloud_network_acl.this.id
  subnet_type    = "PRIVATE"
  usage_type     = "LOADB"
}

resource "ncloud_route_table_association" "lb" {
  count = length(var.lb_subnets)

  route_table_no = ncloud_route_table.private[count.index % local.private_route_table_count].id
  subnet_no      = ncloud_subnet.lb[count.index].id
}

# Public load balancer subnet - required by NKS (lb_public_subnet_no) on the
# public and gov sites.

resource "ncloud_subnet" "public_lb" {
  count = length(var.public_lb_subnets)

  name           = "${var.name}-${var.public_lb_subnet_suffix}-${count.index}"
  vpc_no         = data.ncloud_vpc.this.id
  subnet         = var.public_lb_subnets[count.index]
  zone           = element(var.azs, count.index)
  network_acl_no = ncloud_network_acl.this.id
  subnet_type    = "PUBLIC"
  usage_type     = "LOADB"
}

resource "ncloud_route_table_association" "public_lb" {
  count = length(var.public_lb_subnets)

  route_table_no = ncloud_route_table.public[0].id
  subnet_no      = ncloud_subnet.public_lb[count.index].id
}

# Additional subnets (`subnets`), attached to the module's public or private
# route table by type.

resource "ncloud_subnet" "extra" {
  for_each = local.extra_subnets

  name           = "${var.name}-${each.value.key}-${each.value.index}"
  vpc_no         = data.ncloud_vpc.this.id
  subnet         = each.value.cidr
  zone           = element(var.azs, each.value.index)
  network_acl_no = ncloud_network_acl.this.id
  subnet_type    = each.value.type
  usage_type     = each.value.usage
}

resource "ncloud_route_table_association" "extra" {
  for_each = local.extra_subnets

  route_table_no = each.value.type == "PUBLIC" ? ncloud_route_table.public[0].id : ncloud_route_table.private[each.value.index % local.private_route_table_count].id
  subnet_no      = ncloud_subnet.extra[each.key].id
}
