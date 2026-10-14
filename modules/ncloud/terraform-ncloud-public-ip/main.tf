# Kept apart from the resources using them (e.g. an ALB created by the NKS ALB
# Ingress Controller) so the address survives when those are recreated.
resource "ncloud_public_ip" "this" {
  for_each = var.public_ips

  description        = each.value.description
  server_instance_no = each.value.server_instance_no

  lifecycle {
    prevent_destroy = true
    # Attaching the IP to a load balancer happens outside Terraform.
    ignore_changes = [server_instance_no]
  }
}
