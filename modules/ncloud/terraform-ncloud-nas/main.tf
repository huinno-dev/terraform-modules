locals {
  create = var.create

  # CIFS credentials only apply to a CIFS volume; the protocol code itself is
  # upper case (`NFS` | `CIFS`).
  volume_type = upper(var.type)
}

resource "ncloud_nas_volume" "this" {
  count = local.create ? 1 : 0

  volume_name_postfix            = var.name_postfix
  volume_size                    = var.size
  volume_allotment_protocol_type = local.volume_type
  server_instance_no_list        = var.server_instance_no_list
  cifs_user_name                 = local.volume_type == "CIFS" ? var.cifs_user_name : null
  cifs_user_password             = local.volume_type == "CIFS" ? var.cifs_user_password : null
  description                    = var.description
  zone                           = var.zone
  is_return_protection           = var.return_protection
  is_encrypted_volume            = var.is_encrypted_volume

  timeouts {
    create = var.timeouts.create
    delete = var.timeouts.delete
  }
}
