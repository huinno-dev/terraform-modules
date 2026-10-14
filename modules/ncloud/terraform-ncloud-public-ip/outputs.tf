output "public_ips" {
  description = "Public IPs by name: `public_ip_no` (instance number) and `public_ip` (address)"
  value = {
    for k, ip in ncloud_public_ip.this : k => {
      public_ip_no = ip.public_ip_no
      public_ip    = ip.public_ip
    }
  }
}

output "public_ip_nos" {
  description = "Public IP instance numbers by name"
  value       = { for k, ip in ncloud_public_ip.this : k => ip.public_ip_no }
}
