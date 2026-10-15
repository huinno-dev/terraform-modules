resource "ncloud_mysql" "this" {
  service_name       = var.service_name
  server_name_prefix = var.server_name_prefix
  subnet_no          = var.subnet_no

  user_name     = var.user_name
  user_password = var.user_password
  host_ip       = var.host_ip
  database_name = var.database_name

  engine_version_code = var.engine_version_code
  image_product_code  = var.image_product_code
  product_code        = var.product_code
  data_storage_type   = var.data_storage_type
  port                = var.port

  is_ha                    = var.is_ha
  is_multi_zone            = var.is_multi_zone
  standby_master_subnet_no = var.standby_master_subnet_no
  is_storage_encryption    = var.is_storage_encryption

  is_backup                    = var.is_backup
  backup_file_retention_period = var.backup_file_retention_period
  is_automatic_backup          = var.is_automatic_backup
  backup_time                  = var.backup_time

  lifecycle {
    # Deleting the instance deletes its data.
    prevent_destroy = true

    # A null `is_ha` means the provider default (true).
    precondition {
      condition     = var.is_multi_zone != true || (var.is_ha != false && var.standby_master_subnet_no != null)
      error_message = "is_multi_zone needs is_ha and standby_master_subnet_no."
    }

    precondition {
      condition     = var.standby_master_subnet_no == null || var.is_multi_zone == true
      error_message = "standby_master_subnet_no is only accepted with is_multi_zone = true."
    }

    precondition {
      condition     = var.is_storage_encryption != true || var.is_ha != false
      error_message = "is_storage_encryption needs is_ha."
    }

    precondition {
      condition     = var.is_automatic_backup != false || var.is_backup == false || var.backup_time != null
      error_message = "backup_time is required when is_automatic_backup is false."
    }

    precondition {
      condition     = var.is_automatic_backup == false || var.backup_time == null
      error_message = "backup_time can only be set with is_automatic_backup = false."
    }
  }
}

resource "ncloud_mysql_users" "this" {
  count = nonsensitive(length(var.users)) > 0 ? 1 : 0

  mysql_instance_no = ncloud_mysql.this.id
  mysql_user_list   = var.users
}

resource "ncloud_mysql_databases" "this" {
  count = length(var.databases) > 0 ? 1 : 0

  mysql_instance_no   = ncloud_mysql.this.id
  mysql_database_list = [for name in var.databases : { name = name }]
}
