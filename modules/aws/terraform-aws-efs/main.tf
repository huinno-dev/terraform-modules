
resource "aws_security_group" "efs" {
  name        = "${var.name}-sg"
  description = "Security group for efs in the cluster"

  lifecycle {
    create_before_destroy = true

    precondition {
      condition     = length(var.mount_target_sg) + length(var.allowed_cidr_blocks) > 0
      error_message = "Set mount_target_sg or allowed_cidr_blocks; otherwise nothing can mount the EFS."
    }
  }

  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [data.aws_vpc.this.cidr_block]
  }

  tags = {
    Name      = "${var.name}-sg",
  }
}

resource "aws_security_group_rule" "efs-ingress-worker" {
  count = length(var.mount_target_sg)

  lifecycle {
    create_before_destroy = true
  }

  description              = "Allow EFS from worker"
  security_group_id        = aws_security_group.efs.id
  source_security_group_id = var.mount_target_sg[count.index]
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  type                     = "ingress"
}

resource "aws_security_group_rule" "efs-ingress-cidr" {
  count = length(var.allowed_cidr_blocks) > 0 ? 1 : 0

  description       = "Allow EFS from the given CIDR blocks"
  security_group_id = aws_security_group.efs.id
  cidr_blocks       = var.allowed_cidr_blocks
  from_port         = 2049
  to_port           = 2049
  protocol          = "tcp"
  type              = "ingress"
}

resource "aws_efs_file_system" "efs" {
  creation_token = var.name

  tags = {
    "Name" = var.name
  }
}

resource "aws_efs_mount_target" "efs" {
  count = length(var.subnet_ids)

  file_system_id = aws_efs_file_system.efs.id

  subnet_id = var.subnet_ids[count.index]

  security_groups = [aws_security_group.efs.id]
}