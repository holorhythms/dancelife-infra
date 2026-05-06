// Environment
variable "environment_name" {
    type        = string
    description = "Name of the environment."
}

// Resource groups
variable "resource_group_for_config" {
    type        = string
    default     = "dancelife-infra"
    description = "Name of the resource group for configuration."
}
variable "resource_group_region" {
    type        = string
    default     = "westus2"
    description = "Location of the resource group."
}

// App Service config
variable "app_service_sku_name" {
    type        = string
    description = "SKU for the App Service Plan."
}
variable "app_service_auto_scale_enabled" {
    type        = bool
    default     = false
    description = "Whether or not to enable auto-scaling for the App Service Plan. Only works with Premium plans."
}

// PostgreSQL config
variable "postgres_database_name" {
    type        = string
    default     = "dancelife"
    description = "Name of the PostgreSQL database."
}
variable "postgres_server_sku_name" {
    type        = string
    description = "SKU for the PostgreSQL Flexible Database server."
}
variable "postgres_config_backup_retention_days" {
    type        = number
    default     = 7
    description = "Number of days to retain backups for the PostgreSQL server."
}
variable "postgres_config_geo_redundant_backup_enabled" {
    type        = bool
    default     = false
    description = "Whether or not geo-redundant backup is enabled for the PostgreSQL server."
}
variable "postgres_config_secure_transport" {
    type        = string
    default     = "OFF"
    description = "Whether or not require_secure_transport is on or off for the Postgres server"
}

# Azure Storage config
variable "storage_account_delete_logs_enabled" {
    type        = bool
    default     = true
    description = "Whether or not to enable logging of delete operations in the storage account."
}
variable "storage_account_read_logs_enabled" {
    type        = bool
    default     = false
    description = "Whether or not to enable logging of read operations in the storage account."
}
variable "storage_account_write_logs_enabled" {
    type        = bool
    default     = true
    description = "Whether or not to enable logging of write operations in the storage account."
}
variable "storage_account_log_retention_policy_days" {
    type        = number
    default     = 3
    description = "Number of days to retain logs for the storage account."
}