locals {
  create = var.acg_id == "" ? true : false

  # Rules are attached to the ACG this module manages *and* to an existing one
  # passed in through `acg_id`.
  create_rules = var.create_rules && (length(var.inbound_rules) > 0 || length(var.outbound_rules) > 0)
}
