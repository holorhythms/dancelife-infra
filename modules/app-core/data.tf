// Secrets from Azure Key Vault
data "azurerm_key_vault" "dancelife_vault" {
    name                = "dancelife-terraform"
    resource_group_name = var.resource_group_for_config
}
data "azurerm_key_vault_secret" "postgres_user" {
    name         = "postgres-user-${var.environment_name}"
    key_vault_id = data.azurerm_key_vault.dancelife_vault.id
}
data "azurerm_key_vault_secret" "postgres_pw" {
    name         = "postgres-pw-${var.environment_name}"
    key_vault_id = data.azurerm_key_vault.dancelife_vault.id
}
data "azurerm_key_vault_secret" "github_pat" {
  name         = "github-pat"
  key_vault_id = data.azurerm_key_vault.dancelife_vault.id
}

// Existing resources to reference
data "azuread_group" "dancelife_admins" {
  display_name = "Admins of DanceLife"
  security_enabled = true
}
data "azuread_service_principal" "dancelife_app" {
  display_name = "dancelife-adonisjs"
}
data "azurerm_client_config" "current" {}