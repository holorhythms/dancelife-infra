# // Secrets from Azure Key Vault
# data "azurerm_key_vault" "dancelife_vault" {
#     name                = "dancelife-terraform"
#     resource_group_name = var.resource_group_for_config
# }
# data "azurerm_key_vault_secret" "adonis_app_key" {
#     name         = "adonis-app-key"
#     key_vault_id = data.azurerm_key_vault.dancelife_vault.id
# }
# data "azurerm_key_vault_secret" "google_maps_api_key" {
#     name         = "google-maps-api-key"
#     key_vault_id = data.azurerm_key_vault.dancelife_vault.id
# }
# data "azurerm_key_vault_secret" "postgres_prod_user" {
#     name         = "postgres-prod-user"
#     key_vault_id = data.azurerm_key_vault.dancelife_vault.id
# }
# data "azurerm_key_vault_secret" "postgres_prod_pw" {
#     name         = "postgres-prod-pw"
#     key_vault_id = data.azurerm_key_vault.dancelife_vault.id
# }
# data "azurerm_key_vault_secret" "workos_api_key" {
#     name         = "workos-api-key"
#     key_vault_id = data.azurerm_key_vault.dancelife_vault.id
# }
# data "azurerm_key_vault_secret" "workos_client_id" {
#     name         = "workos-client-id"
#     key_vault_id = data.azurerm_key_vault.dancelife_vault.id
# }
# data "azurerm_key_vault_secret" "workos_cookie_pw" {
#     name         = "workos-cookie-pw"
#     key_vault_id = data.azurerm_key_vault.dancelife_vault.id
# }

# // Existing resources to reference
# data "azuread_group" "dancelife_admins" {
#   display_name = "Admins of DanceLife"
#   security_enabled = true
# }
# data "azuread_service_principal" "dancelife_app" {
#   display_name = "dancelife-adonisjs"
# }
# data "azurerm_client_config" "current" {}

# // Locals definitions
# locals {
#     app_service_name = "dancelife-app-service-${var.environment_name}"
#     postgres_server_name = "dancelife-postgres-server-${var.environment_name}"
#     resource_group_name = "dancelife-rg-${var.environment_name}"
#     storage_account_name = "dancelifestorage${var.environment_name}"
# }

# // Variable definitions
# variable "environment_name" {
#     type        = string
#     default     = "dev"
#     description = "Name of the environment."
# }
# variable "postgres_database_name" {
#     type        = string
#     default     = "dancelife"
#     description = "Name of the PostgreSQL database."
# }
# variable "resource_group_for_config" {
#     type        = string
#     default     = "dancelife-general"
#     description = "Name of the resource group for configuration."
# }
# variable "resource_group_region" {
#     type        = string
#     default     = "westus2"
#     description = "Location of the resource group."
# }