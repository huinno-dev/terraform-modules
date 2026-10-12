locals {
  # Per-app values with `var.defaults` underneath. Doing the merge once here
  # keeps every argument below a single lookup instead of a two-level `try`.
  apps = { for k, v in var.apps : k => merge(var.defaults, v) }

  # helm provider 3.x takes `set` / `set_sensitive` / `set_list` as list
  # attributes instead of repeatable blocks. The map form the block-based
  # interface used is still accepted: a single-variable `for` iterates a map by
  # value and a list by element, so both shapes normalise to a list here.
  set = {
    for k, v in local.apps : k => try([for s in v.set : s], null)
  }

  set_sensitive = {
    for k, v in local.apps : k => try([for s in v.set_sensitive : s], null)
  }

  set_list = {
    for k, v in local.apps : k => try([for s in v.set_list : s], null)
  }
}
