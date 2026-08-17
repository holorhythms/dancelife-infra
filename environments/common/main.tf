// Resources to manage via Terraform
resource "azurerm_resource_group" "rg" {
  location = var.resource_group_region
  name     = local.resource_group_name
}
resource "azurerm_storage_account" "common_storage" {
  account_replication_type        = "RAGRS"
  account_tier                    = "Standard"
  allow_nested_items_to_be_public = false
  location                        = var.resource_group_region
  name                            = local.storage_account_name
  resource_group_name             = azurerm_resource_group.rg.name
  min_tls_version                 = "TLS1_2"
}
resource "azurerm_storage_container" "event_import_files" {
  name                  = "event-import-files"
  storage_account_id  = azurerm_storage_account.common_storage.id
  container_access_type = "private"
}
resource "azurerm_role_assignment" "storage_admins_assignment" {
  scope                = azurerm_storage_account.common_storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azuread_group.dancelife_admins.object_id
  principal_type       = "Group"
}
resource "azurerm_role_assignment" "storage_app_assignment" {
  scope                = azurerm_storage_account.common_storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azuread_service_principal.dancelife_app.object_id
  principal_type       = "ServicePrincipal"
}
resource "azurerm_storage_account_queue_properties" "storage_queue_properties" {
  storage_account_id = azurerm_storage_account.common_storage.id
  hour_metrics {
    version = "1.0"
  }
  logging {
    version = "1.0"
    delete  = var.storage_account_delete_logs_enabled
    read    = var.storage_account_read_logs_enabled
    write   = var.storage_account_write_logs_enabled
    retention_policy_days = var.storage_account_log_retention_policy_days
  }
  minute_metrics {
    version = "1.0"
  }
}