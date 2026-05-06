terraform {

    backend "azurerm" {
        resource_group_name  = "dancelife-infra"
        storage_account_name = "dancelifeterraform"
        container_name       = "terraform-states"
        key                  = "dancelife-dev.tfstate"
    }

    required_providers {
        azurerm = {
            source  = "hashicorp/azurerm"
            version = "~>4.0"
        }
        azapi = {
            source  = "Azure/azapi"
            version = "~>1.13"
        }
        random = {
            source  = "hashicorp/random"
            version = "~>3.0"
        }
    }
}