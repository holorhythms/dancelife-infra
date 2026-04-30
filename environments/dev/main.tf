// Resources to manage via Terraform
resource "azurerm_resource_group" "rg" {
  location = var.resource_group_region
  name     = var.resource_group_name
}
resource "azurerm_postgresql_flexible_server" "main_app_db" {
  location            = var.resource_group_region
  name                = var.postgres_server_name
  resource_group_name = azurerm_resource_group.rg.name
  zone                = "2"
  administrator_login           = data.azurerm_key_vault_secret.postgres_prod_user.value
  administrator_password        = data.azurerm_key_vault_secret.postgres_prod_pw.value
  sku_name = "B_Standard_B2s"
  version = "17"

  authentication {
    active_directory_auth_enabled = true
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
resource "azurerm_postgresql_flexible_server_configuration" "main_app_db_gdal" {
  name      = "postgis.gdal_enabled_drivers"
  server_id = azurerm_postgresql_flexible_server.main_app_db.id
  value     = "DISABLE_ALL"
}
resource "azurerm_postgresql_flexible_server_configuration" "main_app_db_secure_transport" {
  name      = "require_secure_transport"
  server_id = azurerm_postgresql_flexible_server.main_app_db.id
  value     = "OFF"
}
resource "azurerm_postgresql_flexible_server_database" "main_app_db_database" {
  name      = "dancelife"
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
  name                  = "link-jb5466scctmlc"
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
  name                = "vnet-xwnohgdm"
  resource_group_name = azurerm_resource_group.rg.name
}
resource "azurerm_subnet" "subnet_db" {
  address_prefixes     = ["10.0.2.0/24"]
  name                 = "subnet-jb5466scctmlc"
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
  name                 = "subnet-mbovmyie"
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
  name                            = var.storage_account_name
  resource_group_name             = azurerm_resource_group.rg.name
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
resource "azurerm_storage_account_queue_properties" "storage_queue_properties" {
  storage_account_id = azurerm_storage_account.main_storage.id
  hour_metrics {
    version = "1.0"
  }
  logging {
    delete  = false
    read    = false
    version = "1.0"
    write   = false
  }
  minute_metrics {
    version = "1.0"
  }
}
resource "azurerm_service_plan" "app_service_plan" {
  location            = var.resource_group_region
  name                = "ASP-dancelifedev2-ad60"
  os_type             = "Linux"
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "B1"
}
resource "azurerm_linux_web_app" "main_app_service" {
  app_settings = {
    APPLICATIONINSIGHTS_CONNECTION_STRING      = "InstrumentationKey=6569cf1a-c576-4f82-9347-5ddea2cd88cf;IngestionEndpoint=https://westus3-1.in.applicationinsights.azure.com/;LiveEndpoint=https://westus3.livediagnostics.monitor.azure.com/;ApplicationId=a4cdcf56-403b-4742-a06d-ed8c6a5d24f9"
    APP_KEY                                    = data.azurerm_key_vault_secret.adonis_app_key.value
    AZURE_STORAGE_ACCOUNT_NAME                 = var.storage_account_name
    AZURE_STORAGE_ACCOUNT_URL                  = "https://${var.storage_account_name}.blob.core.windows.net"
    AZURE_STORAGE_CONTAINER_ENVIRONMENT_PREFIX = "azure-dev"
    ApplicationInsightsAgent_EXTENSION_VERSION = "~3"
    DB_DATABASE                                = var.postgres_database_name
    DB_HOST                                    = "${var.postgres_server_name}.postgres.database.azure.com"
    DB_PASSWORD                                = data.azurerm_key_vault_secret.postgres_prod_pw.value
    DB_PORT                                    = "5432"
    DB_USER                                    = data.azurerm_key_vault_secret.postgres_prod_user.value
    GOOGLE_MAPS_API_KEY                        = data.azurerm_key_vault_secret.google_maps_api_key.value
    HOST                                       = "0.0.0.0"
    LOG_LEVEL                                  = "debug"
    LOG_LEVEL_CLI                              = "info"
    NODE_ENV                                   = "development"
    PORT                                       = "8080"
    SESSION_DRIVER                             = "cookie"
    WEBSITES_PORT                              = "8080"
    WORKOS_API_KEY                             = data.azurerm_key_vault_secret.workos_api_key.value
    WORKOS_CLIENT_ID                           = data.azurerm_key_vault_secret.workos_client_id.value
    WORKOS_COOKIE_PASSWORD                     = data.azurerm_key_vault_secret.workos_cookie_pw.value
    XDT_MicrosoftApplicationInsights_Mode      = "default"
  }
  https_only          = true
  location            = var.resource_group_region
  name                = var.app_service_name
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.app_service_plan.id
  tags = {
    "hidden-link: /app-insights-resource-id" = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}/providers/microsoft.insights/components/${var.app_service_name}"
  }
  virtual_network_subnet_id = azurerm_subnet.subnet_app.id
  connection_string {
    name  = "AZURE_POSTGRESQL_CONNECTIONSTRING"
    type  = "Custom"
    value = "Database=${var.postgres_database_name};Server=${var.postgres_server_name}.postgres.database.azure.com;User Id=${data.azurerm_key_vault_secret.postgres_prod_user.value};Password=${data.azurerm_key_vault_secret.postgres_prod_pw.value}"
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
      allowed_origins = ["http://localhost:3000", "http://localhost:3333", "https://localhost:3000", "https://localhost:3333", "https://white-moss-02cf3a71e.2.azurestaticapps.net"]
    }
  }
}
resource "azurerm_application_insights" "app_service_insights" {
  application_type    = "web"
  location            = var.resource_group_region
  name                = var.app_service_name
  resource_group_name = azurerm_resource_group.rg.name
  sampling_percentage = 0
}
