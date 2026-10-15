variable "service_name" {
  description = "Cloud DB for MySQL service name (3-30 chars)"
  type        = string
}

variable "server_name_prefix" {
  description = "DB server name prefix (3-20 chars, lowercase letters, digits, `-`)"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,18}[a-z0-9]$", var.server_name_prefix))
    error_message = "server_name_prefix must be 3-20 chars of lowercase letters, digits and -, starting with a letter and ending with a letter or digit."
  }
}

variable "subnet_no" {
  description = "Subnet for the master server. A public domain is only available on a public subnet"
  type        = string
}

variable "user_name" {
  description = "Admin user created with the instance (4-16 chars)"
  type        = string
}

variable "user_password" {
  description = "Admin user password (8-20 chars; letters, digits and a special character, not ` & + \\ \" ' / or space)"
  type        = string
  sensitive   = true
}

variable "host_ip" {
  description = "Host the admin user may connect from: `%`, `10.0.1.10`, `10.0.1.%`"
  type        = string
}

variable "database_name" {
  description = "Database created with the instance"
  type        = string
}

variable "engine_version_code" {
  description = "MySQL engine version, e.g. `8.0.36`. Null uses the current default"
  type        = string
  default     = null
}

variable "image_product_code" {
  description = "Server image product code (`ncloud_mysql_image_products`). Null uses the default"
  type        = string
  default     = null
}

variable "product_code" {
  description = "Server spec product code (`ncloud_mysql_products`). Null uses the minimum spec"
  type        = string
  default     = null
}

variable "data_storage_type" {
  description = "`SSD` / `HDD` on G2 images, `CB2` on G3. Null uses the generation default"
  type        = string
  default     = null
}

variable "is_ha" {
  description = "Create a Standby Master as well. Provider default: true"
  type        = bool
  default     = null
}

variable "is_multi_zone" {
  description = "Put the Standby Master in another zone. Needs HA and `standby_master_subnet_no`"
  type        = bool
  default     = null
}

variable "standby_master_subnet_no" {
  description = "Subnet for the Standby Master; another zone, same public/private type as `subnet_no`"
  type        = string
  default     = null
}

variable "is_storage_encryption" {
  description = "Encrypt data storage. Needs HA and cannot be changed after creation"
  type        = bool
  default     = null
}

variable "is_backup" {
  description = "Daily backup. Always on with HA"
  type        = bool
  default     = null
}

variable "backup_file_retention_period" {
  description = "Backup retention in days (1-30)"
  type        = number
  default     = null

  validation {
    condition     = var.backup_file_retention_period == null || (var.backup_file_retention_period >= 1 && var.backup_file_retention_period <= 30)
    error_message = "backup_file_retention_period must be between 1 and 30."
  }
}

variable "is_automatic_backup" {
  description = "Let NCloud pick the backup time. Provider default: true"
  type        = bool
  default     = null
}

variable "backup_time" {
  description = "Backup time, e.g. `01:15`. Required when `is_automatic_backup` is false"
  type        = string
  default     = null
}

variable "port" {
  description = "MySQL port: 3306 (default) or 10000-20000"
  type        = number
  default     = null

  validation {
    condition     = var.port == null || var.port == 3306 || (var.port >= 10000 && var.port <= 20000)
    error_message = "port must be 3306 or between 10000 and 20000."
  }
}

variable "users" {
  description = "Additional DB users. `authority` is READ, CRUD or DDL"
  type = list(object({
    name                   = string
    password               = string
    host_ip                = string
    authority              = string
    is_system_table_access = optional(bool)
  }))
  default   = []
  sensitive = true

  validation {
    condition     = alltrue([for u in var.users : contains(["READ", "CRUD", "DDL"], u.authority)])
    error_message = "users[].authority must be READ, CRUD or DDL."
  }
}

variable "databases" {
  description = "Additional databases"
  type        = list(string)
  default     = []
}
