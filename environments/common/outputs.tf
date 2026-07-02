output "environment_name" {
    value = var.environment_name
}
output "resource_group_name" {
    value = azurerm_resource_group.rg.name
}
output "azure_storage_account_id" {
    value = azurerm_storage_account.common_storage.id
}
output "azure_storage_account_name" {
    value = azurerm_storage_account.common_storage.name
}