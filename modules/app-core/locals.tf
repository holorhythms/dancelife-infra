// Locals definitions
locals {
    app_service_name = "dancelife-app-service-${var.environment_name}"
    postgres_server_name = "dancelife-postgres-server-${var.environment_name}"
    resource_group_name = "dancelife-rg-${var.environment_name}"
    storage_account_name = "dancelifestorage${var.environment_name}"
    web_portal_name = "dancelife-web-portal-${var.environment_name}"
}
