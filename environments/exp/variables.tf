// Account and environment configuration
variable "subscription_id" {
    type        = string
    description = "Azure subscription ID."
}
variable "environment_name" {
    type        = string
    default     = "exp"
    description = "Name of the environment."
}

// Alerts
variable "critical_alerts_action_group_email_receivers" {
    type = list(object({
        name                    = string
        email_address           = string
        use_common_alert_schema = optional(bool, true)
    }))
    default     = []
    description = "Email receivers for the critical alerts Action Group."
}
variable "critical_alerts_action_group_sms_receivers" {
    type = list(object({
        name         = string
        country_code = string
        phone_number = string
    }))
    default     = []
    description = "SMS receivers for the critical alerts Action Group."
}

variable "main_app_db_storage_percent_alert_enabled" {
    type        = bool
    default     = false
    description = "Whether or not to enable the storage percentage alert for the main PostgreSQL server."
}
variable "main_app_db_storage_percent_alert_threshold_percentage" {
    type        = number
    default     = 85
    description = "Storage percentage threshold that triggers the main PostgreSQL alert."
}