locals {
  create_config_group = var.config_group_no == null
  config_group_no     = local.create_config_group ? ncloud_redis_config_group.this[0].id : var.config_group_no

  # Backup is on when asked for or implied by HA (provider forces it).
  backup_on = var.is_backup == true || var.is_ha == true
}
