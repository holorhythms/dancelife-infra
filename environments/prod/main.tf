module "app_core" {
    source = "../../modules/app-core"

    environment_name = var.environment_name
    resource_group_region = "centralus"

    # Alerts configuration
    app_service_cpu_alert_enabled = true
    app_service_failed_requests_alert_enabled = true
    app_service_ping_test_consecutive_failures_alert_enabled = true
    main_app_db_active_connections_alert_enabled = true
    main_app_db_cpu_alert_enabled = true
    main_app_db_storage_percent_alert_enabled = true

    critical_alerts_action_group_email_receivers = var.critical_alerts_action_group_email_receivers
    critical_alerts_action_group_sms_receivers = var.critical_alerts_action_group_sms_receivers

    # App Service configuration
    app_service_sku_name = "P1v3"
    app_service_hostname = "api.dancelife247.com"
    app_service_autoscale_enabled = true // use module defaults
    app_service_local_dev_origins = []
    app_service_log_level = "info"
    app_service_sampling_percentage = 100

    # PostgreSQL configuration
    postgres_server_sku_name = "GP_Standard_D2s_v3"
    postgres_config_auto_grow_enabled = true
    postgres_config_backup_retention_days = 14
    postgres_config_geo_redundant_backup_enabled = false
    postgres_config_high_availability_enabled = true
    postgres_config_secure_transport = "ON"

    # Storage account configuration
    storage_account_delete_logs_enabled = true
    storage_account_read_logs_enabled = false
    storage_account_write_logs_enabled = true
    storage_account_log_retention_policy_days = 7
}