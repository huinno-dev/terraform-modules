output "vpc_id" {
  description = "The ID of the VPC"
  value       = data.ncloud_vpc.this.id
}

output "vpc_no" {
  description = "The number of the VPC (same value as `vpc_id`)"
  value       = data.ncloud_vpc.this.vpc_no
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = data.ncloud_vpc.this.ipv4_cidr_block
}

output "vpc_default_network_acl" {
  description = "The ID of the Network ACL created by default on VPC creation"
  value       = data.ncloud_vpc.this.default_network_acl_no
}

output "vpc_default_access_control_group" {
  description = "The ID of the ACG created by default on VPC creation"
  value       = data.ncloud_vpc.this.default_access_control_group_no
}

output "vpc_default_public_route_table" {
  description = "The ID of the public route table created by default on VPC creation"
  value       = data.ncloud_vpc.this.default_public_route_table_no
}

output "vpc_default_private_route_table" {
  description = "The ID of the private route table created by default on VPC creation"
  value       = data.ncloud_vpc.this.default_private_route_table_no
}

output "vpc_network_acl" {
  description = "The ID of the Network ACL managed by this module"
  value       = ncloud_network_acl.this.id
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = ncloud_subnet.public[*].subnet_no
}

output "public_subnets_cidr_blocks" {
  description = "List of CIDR blocks of public subnets"
  value       = ncloud_subnet.public[*].subnet
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = ncloud_subnet.private[*].subnet_no
}

output "private_subnets_cidr_blocks" {
  description = "List of CIDR blocks of private subnets"
  value       = ncloud_subnet.private[*].subnet
}

output "lb_subnets" {
  description = "List of IDs of private load balancer subnets"
  value       = ncloud_subnet.lb[*].subnet_no
}

output "lb_subnets_cidr_blocks" {
  description = "List of CIDR blocks of private load balancer subnets"
  value       = ncloud_subnet.lb[*].subnet
}

output "public_lb_subnets" {
  description = "List of IDs of public load balancer subnets"
  value       = ncloud_subnet.public_lb[*].subnet_no
}

output "public_lb_subnets_cidr_blocks" {
  description = "List of CIDR blocks of public load balancer subnets"
  value       = ncloud_subnet.public_lb[*].subnet
}

output "nat_subnets" {
  description = "List of IDs of the subnets dedicated to the NAT Gateways"
  value       = ncloud_subnet.nat[*].subnet_no
}

output "public_route_table" {
  description = "The ID of the public route table managed by this module"
  value       = try(ncloud_route_table.public[0].id, null)
}

output "private_route_tables" {
  description = "List of IDs of the private route tables managed by this module"
  value       = ncloud_route_table.private[*].id
}

output "nat_gateway_ids" {
  description = "List of IDs of the NAT Gateways"
  value       = ncloud_nat_gateway.this[*].id
}

output "nat_public_ips" {
  description = "List of public IPs allocated to the NAT Gateways"
  value       = ncloud_nat_gateway.this[*].public_ip
}

output "azs" {
  description = "A list of availability zones specified as argument to this module"
  value       = var.azs
}

output "subnet_ids" {
  description = "IDs of the `subnets` entries by key, in `cidrs` order"
  value = {
    for k, s in var.subnets : k => [for i, _ in s.cidrs : ncloud_subnet.extra["${k}-${i}"].subnet_no]
  }
}

output "subnet_cidr_blocks" {
  description = "CIDR blocks of the `subnets` entries by key"
  value = {
    for k, s in var.subnets : k => [for i, _ in s.cidrs : ncloud_subnet.extra["${k}-${i}"].subnet]
  }
}
