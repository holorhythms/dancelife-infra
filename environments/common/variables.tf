// Environment
variable "environment_name" {
    type        = string
    description = "Name of the environment."
    default = "common"
}

// Subscription
variable "subscription_id" {
    type        = string
    description = "Azure subscription ID."
}

// Resource group
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

// Storage account
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