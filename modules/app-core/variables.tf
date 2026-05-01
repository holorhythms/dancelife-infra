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
variable "resource_group_for_config" {
    type        = string
    default     = "dancelife-general"
    description = "Name of the resource group for configuration."
}
variable "resource_group_region" {
    type        = string
    default     = "westus2"
    description = "Location of the resource group."
}