output "vpc_id" {
  value = data.aws_vpc.this.id
}

output "vpc_cidr_block" {
  value = data.aws_vpc.this.cidr_block
}

output "public_subnets" {
  value = length(var.public_subnet_ids) > 0 ? data.aws_subnets.public.ids : aws_subnet.public.*.id
}

output "public_subnets_cidr_blocks" {
  value = length(var.public_subnet_ids) > 0 ? [for s in data.aws_subnet.public : s.cidr_block] : aws_subnet.public.*.cidr_block
}

output "private_subnets" {
  value = aws_subnet.private.*.id
}

output "private_subnets_cidr_blocks" {
  value = aws_subnet.private.*.cidr_block
}

output "nat_public_ips" {
  value = aws_eip.nat.*.public_ip
}

output "azs" {
  description = "A list of availability zones specified as argument to this module"
  value       = var.azs
}