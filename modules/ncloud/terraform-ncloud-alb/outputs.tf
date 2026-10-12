output "lb_id" {
  description = "The ID of the load balancer"
  value       = try(ncloud_lb.this[0].id, null)
}

output "lb_no" {
  description = "The number of the load balancer (same value as `lb_id`)"
  value       = try(ncloud_lb.this[0].load_balancer_no, null)
}

output "lb_domain" {
  description = "Domain name of the load balancer"
  value       = try(ncloud_lb.this[0].domain, null)
}

output "lb_ip_list" {
  description = "A list of IP addresses of the load balancer"
  value       = try(ncloud_lb.this[0].ip_list, [])
}

output "lb_vpc_no" {
  description = "The ID of the VPC the load balancer is associated with"
  value       = try(ncloud_lb.this[0].vpc_no, null)
}

output "listener_id" {
  description = "List of IDs of the listeners"
  value       = [for ls in ncloud_lb_listener.this : ls.id]
}

output "listener_ids" {
  description = "Map of listener key to listener ID"
  value       = { for k, ls in ncloud_lb_listener.this : k => ls.id }
}

output "target_group_id" {
  description = "List of IDs of the target groups"
  value       = ncloud_lb_target_group.this[*].id
}

output "target_group_names" {
  description = "List of names of the target groups"
  value       = ncloud_lb_target_group.this[*].name
}
