output "id" {
  description = "MySQL instance number"
  value       = ncloud_mysql.this.id
}

output "vpc_no" {
  description = "VPC of the instance"
  value       = ncloud_mysql.this.vpc_no
}

output "access_control_group_no_list" {
  description = "ACGs attached to the DB servers; add client rules here"
  value       = ncloud_mysql.this.access_control_group_no_list
}

output "port" {
  description = "MySQL port"
  value       = ncloud_mysql.this.port
}

output "master_private_domain" {
  description = "Private domain of the master server"
  value       = try([for s in ncloud_mysql.this.mysql_server_list : s.private_domain if s.server_role == "M"][0], null)
}

output "servers" {
  description = "DB servers: name, role (M master, H standby), zone, domains"
  value = [for s in ncloud_mysql.this.mysql_server_list : {
    name           = s.server_name
    role           = s.server_role
    zone           = s.zone_code
    private_domain = s.private_domain
    public_domain  = s.public_domain
  }]
}
