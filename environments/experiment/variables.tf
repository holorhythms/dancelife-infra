// Retrieve the current Azure client configuration
data "azurerm_client_config" "current" {}

// Define variables
variable "environment_name" {
    type        = string
    default     = "experiment"
    description = "Name of the environment."
}