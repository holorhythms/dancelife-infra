// Locals definitions
locals {
    resource_group_name = "dancelife-rg-${var.environment_name}"
    storage_account_name = "dancelifestorage${var.environment_name}"
}
