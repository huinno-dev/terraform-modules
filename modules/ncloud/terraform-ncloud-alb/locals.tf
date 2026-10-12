locals {
  create_lb = var.create_lb

  # Targets declared inline on a target group become their own attachment so
  # the server list can be changed without recreating the group.
  target_group_attachments = local.create_lb ? {
    for idx, tg in var.target_groups :
    tostring(idx) => {
      target_group_index = idx
      target_no_list     = tg.target_no_list
    }
    if try(length(tg.target_no_list), 0) > 0
  } : {}
}
