output "environment_name" {
    value = var.environment_name
}
output "resource_group_name" {
    value = module.app_core.resource_group_name
}
output "app_service_id" {
    value = module.app_core.app_service_id
}
output "app_service_name" {
    value = module.app_core.app_service_name
}
output "azure_storage_account_id" {
    value = module.app_core.azure_storage_account_id
}
output "azure_storage_account_name" {
    value = module.app_core.azure_storage_account_name
}
output "postgres_server_id" {
    value = module.app_core.postgres_server_id
}
output "postgres_server_name" {
    value = module.app_core.postgres_server_name
}