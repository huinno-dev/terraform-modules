resource "ncloud_lb_target_group" "this" {
  count = local.create_lb ? length(var.target_groups) : 0

  name        = try(var.target_groups[count.index].name, null)
  port        = try(var.target_groups[count.index].port, null)
  protocol    = upper(var.target_groups[count.index].protocol)
  description = try(var.target_groups[count.index].description, null)
  vpc_no      = try(var.target_groups[count.index].vpc_no, var.vpc_no)

  target_type        = try(upper(var.target_groups[count.index].target_type), null)
  algorithm_type     = try(upper(var.target_groups[count.index].algorithm_type), null)
  use_sticky_session = try(var.target_groups[count.index].use_sticky_session, null)
  use_proxy_protocol = try(var.target_groups[count.index].use_proxy_protocol, null)

  dynamic "health_check" {
    for_each = try([var.target_groups[count.index].health_check], [])
    content {
      protocol       = upper(health_check.value.protocol)
      port           = try(health_check.value.port, null)
      http_method    = try(upper(health_check.value.http_method), null)
      url_path       = try(health_check.value.url_path, null)
      cycle          = try(health_check.value.cycle, null)
      up_threshold   = try(health_check.value.up_threshold, null)
      down_threshold = try(health_check.value.down_threshold, null)
    }
  }
}

resource "ncloud_lb_target_group_attachment" "this" {
  for_each = local.target_group_attachments

  target_group_no = ncloud_lb_target_group.this[each.value.target_group_index].id
  target_no_list  = each.value.target_no_list
}

resource "ncloud_lb" "this" {
  count = local.create_lb ? 1 : 0

  name            = var.name
  description     = var.description
  network_type    = var.network_type
  idle_timeout    = var.idle_timeout
  type            = var.type
  throughput_type = var.throughput_type
  subnet_no_list  = var.subnet_no_list
}

resource "ncloud_lb_listener" "this" {
  for_each = local.create_lb ? var.listeners : {}

  load_balancer_no     = ncloud_lb.this[0].load_balancer_no
  target_group_no      = ncloud_lb_target_group.this[each.value.target_group_index].id
  port                 = each.value.port
  protocol             = upper(each.value.protocol)
  tls_min_version_type = try(each.value.tls_min_version_type, null)
  use_http2            = try(each.value.use_http2, null)
  ssl_certificate_no   = try(each.value.ssl_certificate_no, null)
}
