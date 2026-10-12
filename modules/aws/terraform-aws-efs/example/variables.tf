variable "region" {
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "mount_target_sg" {
  type = list(string)
}
