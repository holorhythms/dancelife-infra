module "app_core" {
    source = "../../modules/app-core"

    environment_name = var.environment_name
}