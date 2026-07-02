// Existing resources to reference
data "azuread_group" "dancelife_admins" {
  display_name = "Admins of DanceLife"
  security_enabled = true
}
data "azuread_service_principal" "dancelife_app" {
  display_name = "dancelife-adonisjs"
}
data "azurerm_client_config" "current" {}