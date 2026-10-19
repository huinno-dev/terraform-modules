output "id" {
  description = "Redis instance number"
  value       = ncloud_redis.this.id
}

output "config_group_no" {
  description = "Config group used by the instance"
  value       = local.config_group_no
}

output "access_control_group_no_list" {
  description = "ACGs attached to the Redis servers; add client rules here"
  value       = ncloud_redis.this.access_control_group_no_list
}

output "port" {
  description = "Redis port"
  value       = ncloud_redis.this.port
}

output "servers" {
  description = "Redis servers: name, role (Stand Alone / Master / Slave), private domain"
  value = [for s in ncloud_redis.this.redis_server_list : {
    name           = s.redis_server_name
    role           = s.redis_server_role
    private_domain = s.private_domain
  }]
}
