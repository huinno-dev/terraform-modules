module "efs" {
  source = "../"

  name       = "seoul-dev-efs"
  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  # NFS access: security groups, CIDR blocks, or both (at least one is required).
  mount_target_sg = var.mount_target_sg
}
