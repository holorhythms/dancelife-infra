// Resources to manage via Terraform
resource "azurerm_resource_group" "rg" {
  location = var.resource_group_region
  name     = local.resource_group_name
}
resource "azurerm_postgresql_flexible_server" "main_app_db" {
  location            = var.resource_group_region
  name                = local.postgres_server_name
  resource_group_name = azurerm_resource_group.rg.name
  administrator_login               = data.azurerm_key_vault_secret.postgres_user.value
  administrator_password_wo         = data.azurerm_key_vault_secret.postgres_pw.value
  administrator_password_wo_version = "1"
  sku_name = var.postgres_server_sku_name
  version = "17"
  backup_retention_days = var.postgres_config_backup_retention_days
  geo_redundant_backup_enabled = var.postgres_config_geo_redundant_backup_enabled
  auto_grow_enabled = var.postgres_config_auto_grow_enabled

  # Only include high availability block if enabled for environment
  dynamic "high_availability" {
    for_each = var.postgres_config_high_availability_enabled ? [1] : []
    
    content {
        mode = "ZoneRedundant"
    }
  }

  authentication {
    tenant_id = data.azurerm_client_config.current.tenant_id
    active_directory_auth_enabled = true
    password_auth_enabled = true
  }

  lifecycle {
    ignore_changes = [ 
      zone,
      high_availability[0].standby_availability_zone
    ]
  }
}
resource "azurerm_postgresql_flexible_server_active_directory_administrator" "main_app_db_admin_group" {
  object_id           = data.azuread_group.dancelife_admins.object_id
  principal_name      = data.azuread_group.dancelife_admins.display_name
  principal_type      = "Group"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_postgresql_flexible_server.main_app_db.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  depends_on = [
    azurerm_postgresql_flexible_server.main_app_db,
  ]
}
resource "azurerm_postgresql_flexible_server_configuration" "main_app_db_timezone" {
  name      = "TimeZone"
  server_id = azurerm_postgresql_flexible_server.main_app_db.id
  value     = "UTC"
}
resource "azurerm_postgresql_flexible_server_configuration" "main_app_db_extensions" {
  name      = "azure.extensions"
  server_id = azurerm_postgresql_flexible_server.main_app_db.id
  value     = "POSTGIS,UUID-OSSP"
}
resource "azurerm_postgresql_flexible_server_configuration" "main_app_db_max_connections" {
  name      = "max_connections"
  server_id = azurerm_postgresql_flexible_server.main_app_db.id
  value     = var.postgres_config_max_connections
}
resource "azurerm_postgresql_flexible_server_configuration" "main_app_db_gdal" {
  name      = "postgis.gdal_enabled_drivers"
  server_id = azurerm_postgresql_flexible_server.main_app_db.id
  value     = "DISABLE_ALL"
}
resource "azurerm_postgresql_flexible_server_configuration" "main_app_db_secure_transport" {
  name      = "require_secure_transport"
  server_id = azurerm_postgresql_flexible_server.main_app_db.id
  value     = var.postgres_config_secure_transport
}
resource "azurerm_postgresql_flexible_server_database" "main_app_db_database" {
  name      = var.postgres_database_name
  server_id = azurerm_postgresql_flexible_server.main_app_db.id
}
resource "azurerm_postgresql_flexible_server_firewall_rule" "main_app_db_firewall_rule_1" {
  end_ip_address   = "0.0.0.0"
  name             = "AllowAllAzureServicesAndResourcesWithinAzureIps_2025-8-7_17-15-31"
  server_id        = azurerm_postgresql_flexible_server.main_app_db.id
  start_ip_address = "0.0.0.0"
}
resource "azurerm_postgresql_flexible_server_firewall_rule" "main_app_db_firewall_rule_2" {
  end_ip_address   = "255.255.255.255"
  name             = "AllowAll_2025-8-7_16-1-12"
  server_id        = azurerm_postgresql_flexible_server.main_app_db.id
  start_ip_address = "0.0.0.0"
}
resource "azurerm_private_dns_zone" "postgres" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
}
resource "azurerm_private_dns_zone_virtual_network_link" "postgres_link" {
  name                  = "vnet-link-${azurerm_virtual_network.main_vnet.name}-${azurerm_private_dns_zone.postgres.name}"
  private_dns_zone_name = azurerm_private_dns_zone.postgres.name
  resource_group_name   = azurerm_resource_group.rg.name
  virtual_network_id    = azurerm_virtual_network.main_vnet.id
  depends_on = [
    azurerm_private_dns_zone.postgres,
  ]
}
resource "azurerm_virtual_network" "main_vnet" {
  address_space       = ["10.0.0.0/16"]
  location            = var.resource_group_region
  name                = "vnet-dancelife-${var.environment_name}"
  resource_group_name = azurerm_resource_group.rg.name
}
resource "azurerm_subnet" "subnet_db" {
  address_prefixes     = ["10.0.2.0/24"]
  name                 = "subnet-dancelife-db-${var.environment_name}"
  resource_group_name  = azurerm_resource_group.rg.name
  service_endpoints    = ["Microsoft.Storage"]
  virtual_network_name = azurerm_virtual_network.main_vnet.name
  delegation {
    name = "dlg-database"
    service_delegation {
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      name    = "Microsoft.DBforPostgreSQL/flexibleServers"
    }
  }
  depends_on = [
    azurerm_virtual_network.main_vnet,
  ]
}
resource "azurerm_subnet" "subnet_app" {
  address_prefixes     = ["10.0.1.0/24"]
  name                 = "subnet-dancelife-app-${var.environment_name}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.main_vnet.name
  delegation {
    name = "delegation"
    service_delegation {
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
      name    = "Microsoft.Web/serverFarms"
    }
  }
  depends_on = [
    azurerm_virtual_network.main_vnet,
  ]
}
resource "azurerm_storage_account" "main_storage" {
  account_replication_type        = "RAGRS"
  account_tier                    = "Standard"
  allow_nested_items_to_be_public = false
  location                        = var.resource_group_region
  name                            = local.storage_account_name
  resource_group_name             = azurerm_resource_group.rg.name
  min_tls_version                 = "TLS1_2"
}
resource "azurerm_role_assignment" "storage_admins_assignment" {
  scope                = azurerm_storage_account.main_storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azuread_group.dancelife_admins.object_id
  principal_type       = "Group"
}
resource "azurerm_role_assignment" "storage_app_assignment" {
  scope                = azurerm_storage_account.main_storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azuread_service_principal.dancelife_app.object_id
  principal_type       = "ServicePrincipal"
}
resource "azurerm_role_assignment" "storage_app_service_assignment" {
  scope                = azurerm_storage_account.main_storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_linux_web_app.main_app_service.identity[0].principal_id
}
resource "azurerm_role_assignment" "common_storage_app_service_assignment" {
  scope                = data.azurerm_storage_account.common_storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_linux_web_app.main_app_service.identity[0].principal_id
  principal_type       = "ServicePrincipal"
}
resource "azurerm_role_assignment" "common_storage_app_service_queue_assignment" {
  scope                = data.azurerm_storage_account.common_storage.id
  role_definition_name = "Storage Queue Data Contributor"
  principal_id         = azurerm_linux_web_app.main_app_service.identity[0].principal_id
  principal_type       = "ServicePrincipal"
}
resource "azurerm_role_assignment" "common_storage_app_service_table_assignment" {
  scope                = data.azurerm_storage_account.common_storage.id
  role_definition_name = "Storage Table Data Contributor"
  principal_id         = azurerm_linux_web_app.main_app_service.identity[0].principal_id
  principal_type       = "ServicePrincipal"
}
resource "azurerm_storage_account_queue_properties" "storage_queue_properties" {
  storage_account_id = azurerm_storage_account.main_storage.id
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
resource "azurerm_service_plan" "app_service_plan" {
  location                        = var.resource_group_region
  name                            = "dancelife-plan-${var.environment_name}"
  os_type                         = "Linux"
  resource_group_name             = azurerm_resource_group.rg.name
  sku_name                        = var.app_service_sku_name
}
resource "azurerm_monitor_autoscale_setting" "app_service_plan_autoscale" {
  count               = var.app_service_autoscale_enabled ? 1 : 0
  name                = "dancelife-plan-autoscale-${var.environment_name}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.resource_group_region
  target_resource_id  = azurerm_service_plan.app_service_plan.id

  profile {
    name = "cpu-based"

    capacity {
      default = tostring(var.app_service_autoscale_default_instance_count)
      minimum = tostring(var.app_service_autoscale_minimum_instance_count)
      maximum = tostring(var.app_service_autoscale_maximum_instance_count)
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.app_service_plan.id
        operator           = "GreaterThan"
        statistic          = "Average"
        threshold          = var.app_service_autoscale_scale_out_cpu_percentage
        time_aggregation   = "Average"
        time_grain         = "PT1M"
        time_window        = var.app_service_autoscale_time_window
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = var.app_service_autoscale_scale_out_cooldown
      }
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.app_service_plan.id
        operator           = "LessThan"
        statistic          = "Average"
        threshold          = var.app_service_autoscale_scale_in_cpu_percentage
        time_aggregation   = "Average"
        time_grain         = "PT1M"
        time_window        = var.app_service_autoscale_time_window
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = var.app_service_autoscale_scale_in_cooldown
      }
    }
  }
}
resource "azurerm_app_service_source_control" "main_app_service_source_control" {
  app_id   = azurerm_linux_web_app.main_app_service.id
  repo_url = var.app_service_repo_url
  branch   = var.app_service_repo_branch

  github_action_configuration {

    generate_workflow_file = var.app_service_github_action_generate_workflow_file_enabled

    code_configuration {
      runtime_stack = "node"
      runtime_version = "22"
    }
  }

  lifecycle {
    ignore_changes = [github_action_configuration]
  }
}
resource "azurerm_linux_web_app" "main_app_service" {
  app_settings = {
    ADMIN_ROLE_SECRET                          = "@Microsoft.KeyVault(VaultName=dancelife-terraform;SecretName=admin-role-secret)"
    APPLICATIONINSIGHTS_CONNECTION_STRING      = azurerm_application_insights.app_service_insights.connection_string
    APP_KEY                                    = "@Microsoft.KeyVault(VaultName=dancelife-terraform;SecretName=adonis-app-key)"
    AZURE_STORAGE_ACCOUNT_NAME                 = local.storage_account_name
    AZURE_STORAGE_ACCOUNT_URL                  = "https://${local.storage_account_name}.blob.core.windows.net"
    AZURE_STORAGE_COMMON_ACCOUNT_NAME          = var.storage_common_account_name
    AZURE_STORAGE_CONTAINER_ENVIRONMENT_PREFIX = "azure-${var.environment_name}"
    AZURE_WEB_JOBS_SCHEDULED_EVENT_IMPORT_ENABLED = var.web_jobs_event_import_enabled ? "true" : "false"
    AzureWebJobsStorage                        = azurerm_storage_account.main_storage.primary_connection_string
    ApplicationInsightsAgent_EXTENSION_VERSION = "~3"
    DB_CONNECTION                              = "postgres"
    DB_DATABASE                                = var.postgres_database_name
    DB_HOST                                    = "${local.postgres_server_name}.postgres.database.azure.com"
    DB_PASSWORD                                = "@Microsoft.KeyVault(VaultName=dancelife-terraform;SecretName=postgres-pw-${var.environment_name})"
    DB_PORT                                    = "5432"
    DB_USER                                    = "@Microsoft.KeyVault(VaultName=dancelife-terraform;SecretName=postgres-user-${var.environment_name})"
    DB_SSL                                     = var.postgres_config_secure_transport == "ON" ? "true" : "false"
    GOOGLE_FORMS_SERVICE_ACCOUNT_KEY           = "@Microsoft.KeyVault(VaultName=dancelife-terraform;SecretName=google-forms-service-account-key)"
    GOOGLE_MAPS_API_KEY                        = "@Microsoft.KeyVault(VaultName=dancelife-terraform;SecretName=google-maps-api-key)"
    HOST                                       = "0.0.0.0"
    HOST_ENV                                   = var.environment_name
    LOG_LEVEL                                  = var.app_service_log_level
    LOG_LEVEL_CLI                              = var.app_service_log_level
    NODE_ENV                                   = "production"
    PORT                                       = "8080"
    PROGRAM_COMMUNITY_SECRET                   = "@Microsoft.KeyVault(VaultName=dancelife-terraform;SecretName=program-community-secret)"
    SESSION_DRIVER                             = "cookie"
    WEBJOBS_DISABLE_SCHEDULE                   = "0"
    WEBJOBS_STOPPED                            = "0"
    WEBSITES_PORT                              = "8080"
    WEBSITE_TIME_ZONE                          = "UTC"
    WORKOS_API_KEY                             = "@Microsoft.KeyVault(VaultName=dancelife-terraform;SecretName=workos-api-key-${var.workos_environment})"
    WORKOS_CLIENT_ID                           = "@Microsoft.KeyVault(VaultName=dancelife-terraform;SecretName=workos-client-id-${var.workos_environment})"
    WORKOS_COOKIE_PASSWORD                     = "@Microsoft.KeyVault(VaultName=dancelife-terraform;SecretName=workos-cookie-pw-${var.workos_environment})"
    XDT_MicrosoftApplicationInsights_Mode      = "default"
  }
  https_only          = true
  location            = var.resource_group_region
  name                = local.app_service_name
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.app_service_plan.id
  tags = {
    "hidden-link: /app-insights-resource-id" = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${local.resource_group_name}/providers/microsoft.insights/components/${local.app_service_insights_name}"
  }
  virtual_network_subnet_id = azurerm_subnet.subnet_app.id
  connection_string {
    name  = "AZURE_POSTGRESQL_CONNECTIONSTRING"
    type  = "Custom"
    value = "@Microsoft.KeyVault(VaultName=dancelife-terraform;SecretName=postgres-connection-string-${var.environment_name})"
    # value = "Database=${var.postgres_database_name};Server=${local.postgres_server_name}.postgres.database.azure.com;User Id=${data.azurerm_key_vault_secret.postgres_user.value};Password=${data.azurerm_key_vault_secret.postgres_pw.value}"
  }
  identity {
    type = "SystemAssigned"
  }
  logs {
    http_logs {
      file_system {
        retention_in_days = 7
        retention_in_mb   = 35
      }
    }
  }
  site_config {
    always_on              = true
    ftps_state             = "FtpsOnly"
    vnet_route_all_enabled = true
    application_stack {
      node_version = "22-lts"
    }
    cors {
      allowed_origins = concat(var.app_service_local_dev_origins, [
        "https://${azurerm_static_web_app.web_portal.default_host_name}",
        "https://${azurerm_static_web_app.admin_dashboard.default_host_name}",
        "https://${var.admin_dashboard_hostname}"
      ])
    }
  }
}
# Scheduled App Service jobs must be deployed as app content under App_Data/Jobs/Triggered,
# not created via an ARM child resource upload without a real script payload.
resource "azurerm_linux_web_app_slot" "main_app_service_staging_slot" {
  name           = "staging"
  app_service_id = azurerm_linux_web_app.main_app_service.id

  app_settings = azurerm_linux_web_app.main_app_service.app_settings

  site_config {
    always_on              = true
    ftps_state             = "FtpsOnly"
  }
}
resource "azurerm_app_service_custom_hostname_binding" "main_app_service_hostname_binding" {
  hostname            = var.app_service_hostname
  app_service_name    = azurerm_linux_web_app.main_app_service.name
  resource_group_name = azurerm_linux_web_app.main_app_service.resource_group_name

  # Lifecycle hook helps prevent race conditions during certificate binding
  lifecycle {
    ignore_changes = [ssl_state, thumbprint]
  }
}
resource "azurerm_app_service_managed_certificate" "main_app_service_certificate" {
  custom_hostname_binding_id = azurerm_app_service_custom_hostname_binding.main_app_service_hostname_binding.id
}
resource "azurerm_app_service_certificate_binding" "ssl_binding" {
  hostname_binding_id = azurerm_app_service_custom_hostname_binding.main_app_service_hostname_binding.id
  certificate_id      = azurerm_app_service_managed_certificate.main_app_service_certificate.id
  ssl_state           = "SniEnabled"
}
resource "azurerm_role_assignment" "app_service_keyvault_assignment" {
  scope                = data.azurerm_key_vault.dancelife_vault.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_linux_web_app.main_app_service.identity[0].principal_id
}
resource "azurerm_log_analytics_workspace" "app_service_insights_workspace" {
  location            = var.resource_group_region
  name                = "${local.app_service_name}-law"
  resource_group_name = azurerm_resource_group.rg.name
}
resource "azurerm_monitor_diagnostic_setting" "main_app_service_diagnostics" {
  name                       = "${local.app_service_name}-diagnostics"
  target_resource_id         = azurerm_linux_web_app.main_app_service.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.app_service_insights_workspace.id

  enabled_log {
    category = "AppServiceHTTPLogs"
  }

  enabled_log {
    category = "AppServiceAppLogs"
  }

  enabled_log {
    category = "AppServiceConsoleLogs"
  }
}
resource "azurerm_application_insights" "app_service_insights" {
  application_type    = "web"
  location            = var.resource_group_region
  name                = local.app_service_insights_name
  resource_group_name = azurerm_resource_group.rg.name
  workspace_id        = azurerm_log_analytics_workspace.app_service_insights_workspace.id
  sampling_percentage = var.app_service_sampling_percentage
}
resource "azurerm_application_insights_standard_web_test" "app_service_ping_test" {
  name                    = "dancelife-app-service-ping-test"
  description             = "Ping test for the main Dancelife app service. Checks the GET login urls API."
  resource_group_name     = azurerm_resource_group.rg.name
  application_insights_id = azurerm_application_insights.app_service_insights.id
  location                = azurerm_application_insights.app_service_insights.location
  geo_locations           = [ "us-fl-mia-edge", "us-ca-sjc-azr" ]
  frequency               = "300"
  enabled                 = true
  request {
    url = "https://${azurerm_linux_web_app.main_app_service.default_hostname}${var.app_service_ping_test_path}"
  }
  validation_rules {
    content {
      content_match      = "status"
      ignore_case        = true
      pass_if_text_found = true
    }
  }
}
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "app_service_ping_test_consecutive_failures" {
  count                  = var.app_service_ping_test_consecutive_failures_alert_enabled ? 1 : 0
  name                 = "dancelife-app-service-ping-test-consecutive-failures-${var.environment_name}"
  resource_group_name  = azurerm_resource_group.rg.name
  location             = var.resource_group_region
  scopes               = [azurerm_log_analytics_workspace.app_service_insights_workspace.id]
  severity             = var.app_service_ping_test_consecutive_failures_alert_severity
  auto_mitigation_enabled = true
  evaluation_frequency = var.ping_test_evaluation_frequency
  window_duration      = var.ping_test_window_duration
  description          = "Alert when the app service ping test fails 2 runs in a row."

  criteria {
    query = <<-KQL
      let testName = "${azurerm_application_insights_standard_web_test.app_service_ping_test.name}";
      AppAvailabilityResults
      | where Name == testName
      | summarize RunSuccess = min(tobool(Success)) by bin(TimeGenerated, 5m)
      | top 2 by TimeGenerated desc
      | summarize ConsecutiveFailures = countif(RunSuccess == false), RunsConsidered = count()
      | where RunsConsidered == 2 and ConsecutiveFailures == 2
      | project ConsecutiveFailures
    KQL

    time_aggregation_method = "Maximum"
    metric_measure_column   = "ConsecutiveFailures"
    operator                = "GreaterThanOrEqual"
    threshold               = 2

    failing_periods {
      number_of_evaluation_periods             = 1
      minimum_failing_periods_to_trigger_alert = 1
    }
  }

  action {
    action_groups = [azurerm_monitor_action_group.critical_alerts.id]
  }
}
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "app_service_failed_request_percentage" {
  count                   = var.app_service_failed_requests_alert_enabled ? 1 : 0
  name                    = "dancelife-app-service-failed-requests-percentage-${var.environment_name}"
  resource_group_name     = azurerm_resource_group.rg.name
  location                = var.resource_group_region
  scopes                  = [azurerm_log_analytics_workspace.app_service_insights_workspace.id]
  severity                = var.app_service_failed_requests_alert_severity
  evaluation_frequency    = var.app_service_failed_requests_alert_evaluation_frequency
  window_duration         = var.app_service_failed_requests_alert_window_duration
  auto_mitigation_enabled = true
  description             = "Alert when App Service failed request percentage exceeds threshold."

  criteria {
    query = <<-KQL
      AppRequests
      | where tostring(ResultCode) != "404"
      | summarize TotalRequests = count(), FailedRequests = countif(Success == false)
      | extend FailedRequestPercentage = iff(TotalRequests == 0, 0.0, todouble(FailedRequests) * 100.0 / todouble(TotalRequests))
      | where FailedRequests >= ${var.app_service_failed_requests_alert_threshold_count}
      | project FailedRequestPercentage
    KQL

    time_aggregation_method = "Maximum"
    metric_measure_column   = "FailedRequestPercentage"
    operator                = "GreaterThan"
    threshold               = var.app_service_failed_requests_alert_threshold_percentage

    failing_periods {
      number_of_evaluation_periods             = 1
      minimum_failing_periods_to_trigger_alert = 1
    }
  }

  action {
      action_groups = [ azurerm_monitor_action_group.critical_alerts.id ]
  }
}
resource "azurerm_monitor_action_group" "critical_alerts" {
  name                = "critical-alerts-${var.environment_name}"
  resource_group_name = azurerm_resource_group.rg.name
  short_name          = "crit-alerts"

  dynamic "email_receiver" {
    for_each = var.critical_alerts_action_group_email_receivers

    content {
      name                    = email_receiver.value.name
      email_address           = email_receiver.value.email_address
      use_common_alert_schema = email_receiver.value.use_common_alert_schema
    }
  }

  dynamic "sms_receiver" {
    for_each = var.critical_alerts_action_group_sms_receivers

    content {
      name         = sms_receiver.value.name
      country_code = sms_receiver.value.country_code
      phone_number = sms_receiver.value.phone_number
    }
  }
}
resource "azurerm_monitor_metric_alert" "main_app_service_cpu_high" {
  count               = var.app_service_cpu_alert_enabled ? 1 : 0
  name                = "dancelife-main-app-service-cpu-high-${var.environment_name}"
  resource_group_name = azurerm_resource_group.rg.name
  scopes              = [azurerm_service_plan.app_service_plan.id]
  description         = "Alert when the main App Service CPU percentage is above the configured threshold."
  severity            = var.app_service_cpu_alert_severity
  frequency           = var.app_service_cpu_alert_evaluation_frequency
  window_size         = var.app_service_cpu_alert_window_size
  auto_mitigate       = true

  criteria {
    metric_namespace = "Microsoft.Web/serverfarms"
    metric_name      = "CpuPercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.app_service_cpu_alert_threshold_percentage
  }

  action {
    action_group_id = azurerm_monitor_action_group.critical_alerts.id
  }
}
resource "azurerm_monitor_metric_alert" "main_app_db_storage_percent_high" {
  count               = var.main_app_db_storage_percent_alert_enabled ? 1 : 0
  name                = "dancelife-main-app-db-storage-percent-high-${var.environment_name}"
  resource_group_name = azurerm_resource_group.rg.name
  scopes              = [azurerm_postgresql_flexible_server.main_app_db.id]
  description         = "Alert when the main PostgreSQL server storage percentage is above the configured threshold."
  severity            = var.main_app_db_storage_percent_alert_severity
  frequency           = var.main_app_db_storage_percent_alert_evaluation_frequency
  window_size         = var.main_app_db_storage_percent_alert_window_size
  auto_mitigate       = true

  criteria {
    metric_namespace = "Microsoft.DBforPostgreSQL/flexibleServers"
    metric_name      = "storage_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.main_app_db_storage_percent_alert_threshold_percentage
  }

  action {
    action_group_id = azurerm_monitor_action_group.critical_alerts.id
  }
}
resource "azurerm_monitor_metric_alert" "main_app_db_cpu_high" {
  count               = var.main_app_db_cpu_alert_enabled ? 1 : 0
  name                = "dancelife-main-app-db-cpu-high-${var.environment_name}"
  resource_group_name = azurerm_resource_group.rg.name
  scopes              = [azurerm_postgresql_flexible_server.main_app_db.id]
  description         = "Alert when the main PostgreSQL server CPU percentage is above the configured threshold."
  severity            = var.main_app_db_cpu_alert_severity
  frequency           = var.main_app_db_cpu_alert_evaluation_frequency
  window_size         = var.main_app_db_cpu_alert_window_size
  auto_mitigate       = true

  criteria {
    metric_namespace = "Microsoft.DBforPostgreSQL/flexibleServers"
    metric_name      = "cpu_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.main_app_db_cpu_alert_threshold_percentage
  }

  action {
    action_group_id = azurerm_monitor_action_group.critical_alerts.id
  }
}
resource "azurerm_monitor_metric_alert" "main_app_db_active_connections_high" {
  count               = var.main_app_db_active_connections_alert_enabled ? 1 : 0
  name                = "dancelife-main-app-db-active-connections-high-${var.environment_name}"
  resource_group_name = azurerm_resource_group.rg.name
  scopes              = [azurerm_postgresql_flexible_server.main_app_db.id]
  description         = "Alert when main PostgreSQL active connections exceeds the configured percentage of max connections."
  severity            = var.main_app_db_active_connections_alert_severity
  frequency           = var.main_app_db_active_connections_alert_evaluation_frequency
  window_size         = var.main_app_db_active_connections_alert_window_size
  auto_mitigate       = true

  criteria {
    metric_namespace = "Microsoft.DBforPostgreSQL/flexibleServers"
    metric_name      = "active_connections"
    aggregation      = "Average"
    operator         = "GreaterThanOrEqual"
    threshold        = ceil((tonumber(var.postgres_config_max_connections) * var.main_app_db_active_connections_alert_threshold_percentage) / 100)
  }

  action {
    action_group_id = azurerm_monitor_action_group.critical_alerts.id
  }
}
resource "azurerm_static_web_app" "web_portal" {
  location            = var.resource_group_region
  name                = local.web_portal_name
  repository_branch   = var.web_portal_branch
  repository_url      = var.web_portal_repo_url
  repository_token    = data.azurerm_key_vault_secret.github_pat.value
  resource_group_name = azurerm_resource_group.rg.name
  sku_size            = var.web_portal_sku_size
  sku_tier            = var.web_portal_sku_tier

  lifecycle {
    ignore_changes = [
      app_settings,
    ]
  }
}
resource "azapi_resource_action" "web_portal_app_settings" {
  type        = "Microsoft.Web/staticSites@2022-09-01"
  resource_id = azurerm_static_web_app.web_portal.id
  action      = "config/appsettings"
  method      = "PUT"

  body = {
    properties = {
      VITE_BACKEND_BASEURL       = "https://${azurerm_linux_web_app.main_app_service.default_hostname}"
      VITE_REDIRECT_FRONTEND_URI = "https://${azurerm_static_web_app.web_portal.default_host_name}"
    }
  }

  response_export_values = []

  depends_on = [
    azurerm_static_web_app.web_portal,
  ]
}
resource "azurerm_static_web_app" "admin_dashboard" {
  location            = var.resource_group_region
  name                = local.admin_dashboard_name
  repository_branch   = var.admin_dashboard_branch
  repository_url      = var.admin_dashboard_repo_url
  repository_token    = data.azurerm_key_vault_secret.github_pat.value
  resource_group_name = azurerm_resource_group.rg.name
  sku_size            = var.admin_dashboard_sku_size
  sku_tier            = var.admin_dashboard_sku_tier

  lifecycle {
    ignore_changes = [
      app_settings,
    ]
  }
}
resource "azapi_resource_action" "admin_dashboard_app_settings" {
  type        = "Microsoft.Web/staticSites@2022-09-01"
  resource_id = azurerm_static_web_app.admin_dashboard.id
  action      = "config/appsettings"
  method      = "PUT"

  body = {
    properties = {
        VITE_API_BASE_URL = "https://${azurerm_linux_web_app.main_app_service.default_hostname}/api/v1"
    }
  }

  response_export_values = []

  depends_on = [
    azurerm_static_web_app.admin_dashboard,
  ]
}
resource "azurerm_static_web_app_custom_domain" "admin_dashboard_hostname_binding" {
  static_web_app_id = azurerm_static_web_app.admin_dashboard.id
  domain_name       = var.admin_dashboard_hostname
  validation_type   = "cname-delegation"
}