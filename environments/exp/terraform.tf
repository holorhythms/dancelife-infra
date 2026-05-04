terraform {

    backend "azurerm" {
        resource_group_name  = "dancelife-infra"
        storage_account_name = "dancelifeterraform"
        container_name       = "terraform-states"
        key                  = "dancelife-exp.tfstate"
    }

    required_providers {
        azurerm = {
            source  = "hashicorp/azurerm"
            version = "~>4.0"
        }
        random = {
            source  = "hashicorp/random"
            version = "~>3.0"
        }
    }
}