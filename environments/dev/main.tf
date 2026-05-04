module "app_core" {
    source = "../../modules/app-core"

    environment_name = var.environment_name

    # PostgreSQL configuration
    postgres_config_backup_retention_days = 7
    postgres_config_geo_redundant_backup_enabled = false
    postgres_config_secure_transport = "OFF"
}