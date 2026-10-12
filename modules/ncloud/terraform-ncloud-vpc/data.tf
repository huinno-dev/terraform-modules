data "ncloud_vpc" "this" {
  id = var.vpc_id == "" ? element(concat(ncloud_vpc.this.*.id, [""]), 0) : var.vpc_id
}