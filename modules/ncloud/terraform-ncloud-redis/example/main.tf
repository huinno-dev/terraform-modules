module "redis" {
  source = "../"

  service_name       = "seoul-dev-redis"
  server_name_prefix = "seoul-dev-rds"
  vpc_no             = "10001"
  subnet_no          = "20004" # private DB subnet (vpc `subnets["db"]`)

  mode          = "SIMPLE"
  redis_version = "7.0.13-simple" # creates the config group

  # Required on the gov site.
  user_name     = "app_user"
  user_password = var.redis_password

  # Standby master with failover; backup is turned on with it.
  is_ha                        = true
  backup_file_retention_period = 7
  is_automatic_backup          = false
  backup_time                  = "04:00"
}

output "servers" {
  value = module.redis.servers
}
