provider "azurerm" {
    features {
        resource_group {
            prevent_deletion_if_contains_resources = false 
        }
    }
    environment                     = "public"
    use_msi                         = false
    use_cli                         = true
    use_oidc                        = false
    resource_provider_registrations = "none"
    subscription_id                 = "43c1cbf6-f1bf-4fac-a945-9ada59578e4a"
}
