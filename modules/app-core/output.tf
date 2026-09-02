output "resource_group_name" {
    value = azurerm_resource_group.rg.name
}
output "app_service_id" {
    value = azurerm_linux_web_app.main_app_service.id
}
output "app_service_name" {
    value = azurerm_linux_web_app.main_app_service.name
}
output "app_service_custom_hostname" {
    value = azurerm_app_service_custom_hostname_binding.main_app_service_hostname_binding.hostname
}
output "app_service_domain_verification_id" {
    value = azurerm_linux_web_app.main_app_service.custom_domain_verification_id
    sensitive = true
}
output "front_door_profile_id" {
    value = azurerm_cdn_frontdoor_profile.main.id
}
output "front_door_endpoint_hostname" {
    value = azurerm_cdn_frontdoor_endpoint.main_app_service.host_name
}
output "front_door_custom_domain_validation_token" {
    value = azurerm_cdn_frontdoor_custom_domain.main_app_service.validation_token
    sensitive = true
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