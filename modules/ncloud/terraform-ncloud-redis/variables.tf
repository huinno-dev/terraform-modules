variable "service_name" {
  description = "Cloud DB for Redis service name (3-15 chars)"
  type        = string

  validation {
    condition     = length(var.service_name) >= 3 && length(var.service_name) <= 15
    error_message = "service_name must be 3-15 chars."
  }
}

variable "server_name_prefix" {
  description = "Redis server name prefix (3-15 chars, lowercase letters, digits, `-`)"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,13}[a-z0-9]$", var.server_name_prefix))
    error_message = "server_name_prefix must be 3-15 chars of lowercase letters, digits and -, starting with a letter and ending with a letter or digit."
  }
}

variable "vpc_no" {
  description = "VPC of the instance"
  type        = string
}

variable "subnet_no" {
  description = "Subnet of the instance. Cannot be changed after creation"
  type        = string
}

variable "mode" {
  description = "`SIMPLE` or `CLUSTER`. `is_ha` is ignored in CLUSTER mode"
  type        = string

  validation {
    condition     = contains(["SIMPLE", "CLUSTER"], var.mode)
    error_message = "mode must be SIMPLE or CLUSTER."
  }
}

variable "user_name" {
  description = "Redis user (4-16 chars). Required on the gov site, not available elsewhere"
  type        = string
  default     = null
}

variable "user_password" {
  description = "Redis user password (8-20 chars). Required on the gov site, not available elsewhere"
  type        = string
  default     = null
  sensitive   = true
}

variable "config_group_no" {
  description = "Existing Redis config group number. Null creates one from `redis_version`"
  type        = string
  default     = null
}

variable "config_group_name" {
  description = "Name of the created config group (3-15 chars). Defaults to `server_name_prefix`"
  type        = string
  default     = null
}

variable "redis_version" {
  description = "Version of the created config group, e.g. `7.0.13-simple` / `7.0.13-cluster`; the suffix must match `mode`"
  type        = string
  default     = null
}

variable "engine_version_code" {
  description = "Redis engine version code. Null uses the current default"
  type        = string
  default     = null
}

variable "image_product_code" {
  description = "Server image product code (`ncloud_redis_image_products`). Null uses the default"
  type        = string
  default     = null
}

variable "product_code" {
  description = "Server spec product code (`ncloud_redis_products`). Null uses the minimum spec"
  type        = string
  default     = null
}

variable "shard_count" {
  description = "Number of shards (3-10). CLUSTER mode only"
  type        = number
  default     = null

  validation {
    condition     = var.shard_count == null || (var.shard_count >= 3 && var.shard_count <= 10)
    error_message = "shard_count must be between 3 and 10."
  }
}

variable "shard_copy_count" {
  description = "Replicas per shard (0-4); 0 means no HA. CLUSTER mode only"
  type        = number
  default     = null

  validation {
    condition     = var.shard_copy_count == null || (var.shard_copy_count >= 0 && var.shard_copy_count <= 4)
    error_message = "shard_copy_count must be between 0 and 4."
  }
}

variable "is_ha" {
  description = "Standby master with automatic failover (SIMPLE mode). Turns backup on. Provider default: false"
  type        = bool
  default     = null
}

variable "is_backup" {
  description = "Daily backup. Always on with HA. Provider default: false"
  type        = bool
  default     = null
}

variable "backup_file_retention_period" {
  description = "Backup retention in days"
  type        = number
  default     = null
}

variable "is_automatic_backup" {
  description = "Let NCloud pick the backup time"
  type        = bool
  default     = null
}

variable "backup_time" {
  description = "Backup time, e.g. `01:15`. Required when backup is on and `is_automatic_backup` is false"
  type        = string
  default     = null
}

variable "port" {
  description = "Redis port: 6379 (default) or 10000-20000"
  type        = number
  default     = null

  validation {
    condition     = var.port == null || var.port == 6379 || (var.port >= 10000 && var.port <= 20000)
    error_message = "port must be 6379 or between 10000 and 20000."
  }
}
