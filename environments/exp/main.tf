module "app_core" {
    source = "../../modules/app-core"

    environment_name = var.environment_name

    # App Service configuration
    app_service_sku_name = "P1v3"
    app_service_auto_scale_enabled = true
    app_service_sampling_percentage = 100

    # PostgreSQL configuration
    postgres_server_sku_name = "GP_Standard_D2s_v3"
    postgres_config_backup_retention_days = 14
    postgres_config_geo_redundant_backup_enabled = true
    postgres_config_secure_transport = "ON"

    # Storage account configuration
    storage_account_delete_logs_enabled = true
    storage_account_read_logs_enabled = false
    storage_account_write_logs_enabled = true
    storage_account_log_retention_policy_days = 7
}