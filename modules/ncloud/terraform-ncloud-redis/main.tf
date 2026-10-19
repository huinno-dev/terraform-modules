resource "ncloud_redis_config_group" "this" {
  count = local.create_config_group ? 1 : 0

  name          = coalesce(var.config_group_name, var.server_name_prefix)
  redis_version = var.redis_version
  description   = "Config group for ${var.service_name}"

  lifecycle {
    precondition {
      condition     = var.redis_version != null
      error_message = "redis_version is required when config_group_no is not set."
    }

    # A config group serves one mode; its version carries the matching suffix.
    precondition {
      condition     = var.redis_version == null || endswith(coalesce(var.redis_version, "-"), "-${lower(var.mode)}")
      error_message = "redis_version must end with -${lower(var.mode)} to match mode ${var.mode}."
    }
  }
}

resource "ncloud_redis" "this" {
  service_name       = var.service_name
  server_name_prefix = var.server_name_prefix
  vpc_no             = var.vpc_no
  subnet_no          = var.subnet_no
  config_group_no    = local.config_group_no
  mode               = var.mode

  user_name     = var.user_name
  user_password = var.user_password

  engine_version_code = var.engine_version_code
  image_product_code  = var.image_product_code
  product_code        = var.product_code
  port                = var.port

  shard_count      = var.shard_count
  shard_copy_count = var.shard_copy_count
  is_ha            = var.is_ha

  is_backup                    = var.is_backup
  backup_file_retention_period = var.backup_file_retention_period
  is_automatic_backup          = var.is_automatic_backup
  backup_time                  = var.backup_time

  lifecycle {
    # Deleting the instance deletes its data.
    prevent_destroy = true

    precondition {
      condition     = var.mode == "CLUSTER" || (var.shard_count == null && var.shard_copy_count == null)
      error_message = "shard_count and shard_copy_count are CLUSTER mode only."
    }

    precondition {
      condition     = (var.user_name == null) == (var.user_password == null)
      error_message = "user_name and user_password go together (required on the gov site)."
    }

    precondition {
      condition     = !local.backup_on || var.is_automatic_backup != false || var.backup_time != null
      error_message = "backup_time is required when backup is on and is_automatic_backup is false."
    }
  }
}
