output "allocation_ids" {
  description = "Allocation IDs ordered by var.azs"
  value       = [for az in var.azs : aws_eip.this[az].id]
}

output "public_ips" {
  description = "Public IPs ordered by var.azs"
  value       = [for az in var.azs : aws_eip.this[az].public_ip]
}

output "allocation_id_by_az" {
  description = "Map of availability zone to allocation ID"
  value       = { for az, eip in aws_eip.this : az => eip.id }
}

output "public_ip_by_az" {
  description = "Map of availability zone to public IP"
  value       = { for az, eip in aws_eip.this : az => eip.public_ip }
}
