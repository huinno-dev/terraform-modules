data "ncloud_access_control_group" "this" {
  id = var.acg_id == "" ? element(concat(ncloud_access_control_group.this.*.id, [""]), 0) : var.acg_id
}