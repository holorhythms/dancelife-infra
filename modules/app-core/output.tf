output "resource_group_name" {
    value = azurerm_resource_group.rg.name
}
output "app_service_id" {
    value = azurerm_linux_web_app.main_app_service.id
}
output "app_service_name" {
    value = azurerm_linux_web_app.main_app_service.name
}
output "azure_storage_account_id" {
    value = azurerm_storage_account.main_storage.id
}
output "azure_storage_account_name" {
    value = azurerm_storage_account.main_storage.name
}
output "postgres_server_id" {
    value = azurerm_postgresql_flexible_server.main_app_db.id
}
output "postgres_server_name" {
    value = azurerm_postgresql_flexible_server.main_app_db.name
}