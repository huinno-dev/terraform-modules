resource "ncloud_access_control_group" "this" {
  count = local.create ? 1 : 0

  name        = var.name
  description = var.description
  vpc_no      = var.vpc_id
}

# Ncloud applies a single rule set per ACG, so inbound and outbound rules are
# always managed together in one resource.
resource "ncloud_access_control_group_rule" "this" {
  count = local.create_rules ? 1 : 0

  access_control_group_no = data.ncloud_access_control_group.this.id

  dynamic "inbound" {
    for_each = var.inbound_rules
    content {
      protocol                       = inbound.value.protocol
      ip_block                       = try(inbound.value.ip_block, null)
      source_access_control_group_no = try(inbound.value.source_access_control_group_no, null)
      port_range                     = try(inbound.value.port_range, null)
      description                    = try(inbound.value.description, null)
    }
  }

  dynamic "outbound" {
    for_each = var.outbound_rules
    content {
      protocol                       = outbound.value.protocol
      ip_block                       = try(outbound.value.ip_block, null)
      source_access_control_group_no = try(outbound.value.source_access_control_group_no, null)
      port_range                     = try(outbound.value.port_range, null)
      description                    = try(outbound.value.description, null)
    }
  }

  timeouts {
    create = var.timeouts.create
    update = var.timeouts.update
    delete = var.timeouts.delete
  }
}
