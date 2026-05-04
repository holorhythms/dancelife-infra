// Variable definitions
variable "environment_name" {
    type        = string
    description = "Name of the environment."
}
variable "postgres_database_name" {
    type        = string
    default     = "dancelife"
    description = "Name of the PostgreSQL database."
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