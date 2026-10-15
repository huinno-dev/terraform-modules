module "mysql" {
  source = "../"

  service_name       = "seoul-dev-example"
  server_name_prefix = "seoul-dev-db"
  subnet_no          = "20004" # private DB subnet

  user_name     = "admin_user"
  user_password = var.mysql_admin_password
  host_ip       = "10.110.%" # VPC range only
  database_name = "app"

  engine_version_code = "8.0.36"

  # HA across zones: the standby subnet must be in another zone.
  is_ha                    = true
  is_multi_zone            = true
  standby_master_subnet_no = "20005"
  is_storage_encryption    = true

  backup_file_retention_period = 7
  is_automatic_backup          = false
  backup_time                  = "03:00"

  users = [
    {
      name      = "app_user"
      password  = var.mysql_app_password
      host_ip   = "10.110.%"
      authority = "CRUD"
    },
  ]

  databases = ["app_log"]
}

output "master_private_domain" {
  value = module.mysql.master_private_domain
}
