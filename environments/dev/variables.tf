// Define variables
variable "subscription_id" {
    type        = string
    description = "Azure subscription ID."
}
variable "environment_name" {
    type        = string
    default     = "dev"
    description = "Name of the environment."
}