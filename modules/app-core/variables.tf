// Environment
variable "environment_name" {
    type        = string
    description = "Name of the environment."
}
variable "workos_environment" {
    type        = string
    default     = "staging"
    description = "Environment for WorkOS configuration ('staging' or 'prod')."
}

// Resource groups
variable "resource_group_for_config" {
    type        = string
    default     = "dancelife-infra"
    description = "Name of the resource group for configuration."
}
variable "resource_group_region" {
    type        = string
    default     = "westus2"
    description = "Location of the resource group."
}

// General alerts config
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

// Scheduled jobs config
variable "web_jobs_event_import_enabled" {
    type        = bool
    default     = false
    description = "Whether or not to enable the App Service event import scheduled Web Job."
}

// App Service config
variable "app_service_sku_name" {
    type        = string
    description = "SKU for the App Service Plan."
}
variable "app_service_hostname" {
    type        = string
    description = "Hostname for the App Service. This will be used to construct the default URL for the app."
}
variable "app_service_autoscale_enabled" {
    type        = bool
    default     = false
    description = "Whether or not to enable auto-scaling for the App Service Plan. Only works with Premium plans."
}
variable "app_service_autoscale_minimum_instance_count" {
    type        = number
    default     = 2
    description = "Minimum number of App Service Plan instances when autoscale is enabled."
}
variable "app_service_autoscale_default_instance_count" {
    type        = number
    default     = 2
    description = "Default number of App Service Plan instances when autoscale is enabled."
}
variable "app_service_autoscale_maximum_instance_count" {
    type        = number
    default     = 4
    description = "Maximum number of App Service Plan instances when autoscale is enabled."
}
variable "app_service_autoscale_scale_out_cpu_percentage" {
    type        = number
    default     = 75
    description = "Scale out when average CPU percentage is above this value."
}
variable "app_service_autoscale_scale_in_cpu_percentage" {
    type        = number
    default     = 25
    description = "Scale in when average CPU percentage is below this value."
}
variable "app_service_autoscale_scale_out_cooldown" {
    type        = string
    default     = "PT5M"
    description = "Cooldown after a scale-out action."
}
variable "app_service_autoscale_scale_in_cooldown" {
    type        = string
    default     = "PT10M"
    description = "Cooldown after a scale-in action."
}
variable "app_service_autoscale_time_window" {
    type        = string
    default     = "PT10M"
    description = "Time window for evaluating autoscale metrics."
}
variable "app_service_github_action_generate_workflow_file_enabled" {
    type        = bool
    default     = true
    description = "Whether or not to generate the GitHub Actions workflow file for the App Service deployment."
}
variable "app_service_local_dev_origins" {
    type        = list(string)
    default     = [
        "http://localhost:3000", 
        "http://localhost:3333", 
        "https://localhost:3000", 
        "https://localhost:3333"
    ]
    description = "List of allowed CORS origins for local development. These will be added to the App Service CORS settings"
}
variable "app_service_log_level" {
    type        = string
    default     = "debug"
    description = "Log level for the App Service."
}
variable "app_service_ping_test_path" {
    type        = string
    default     = "/api/v1/auth/wos/login/urls"
    description = "Path to use for ping tests in Application Insights availability tests."
}
variable "app_service_repo_branch" {
    type        = string
    default     = "master"
    description = "Branch of the repository to deploy for the App Service."
}
variable "app_service_repo_url" {
    type        = string
    default     = "https://github.com/Kressendo-Innovations/dancelife-adonisjs.git"
    description = "URL of the repository for the App Service."
}
variable "app_service_sampling_percentage" {
    type        = number
    default     = 100
    description = "Percentage of requests to sample for Application Insights."
}

// PostgreSQL config
variable "postgres_database_name" {
    type        = string
    default     = "dancelife"
    description = "Name of the PostgreSQL database."
}
variable "postgres_server_sku_name" {
    type        = string
    description = "SKU for the PostgreSQL Flexible Database server."
}
variable "postgres_config_auto_grow_enabled" {
    type        = bool
    default     = false
    description = "Whether or not to enable auto-grow for the PostgreSQL server."
}
variable "postgres_config_backup_retention_days" {
    type        = number
    default     = 7
    description = "Number of days to retain backups for the PostgreSQL server."
}
variable "postgres_config_geo_redundant_backup_enabled" {
    type        = bool
    default     = false
    description = "Whether or not geo-redundant backup is enabled for the PostgreSQL server."
}
variable "postgres_config_high_availability_enabled" {
    type        = bool
    default     = false
    description = "Whether or not high availability is enabled for the PostgreSQL server. Only works with certain SKUs."
}
variable "postgres_config_max_connections" {
    type        = number
    default     = "859"
    description = "Value for the max_connections configuration on the PostgreSQL server."
}
variable "postgres_config_secure_transport" {
    type        = string
    default     = "OFF"
    description = "Whether or not require_secure_transport is on or off for the Postgres server"
}

# Azure Storage config
variable "storage_common_account_name" {
    type        = string
    default     = "dancelifestoragecommon"
    description = "Name of the common storage account."
}
variable "storage_account_container_name_prefix" {
    type        = string
    description = "Prefix for the main storage container names."
}
variable "storage_account_delete_logs_enabled" {
    type        = bool
    default     = true
    description = "Whether or not to enable logging of delete operations in the storage account."
}
variable "storage_account_read_logs_enabled" {
    type        = bool
    default     = false
    description = "Whether or not to enable logging of read operations in the storage account."
}
variable "storage_account_write_logs_enabled" {
    type        = bool
    default     = true
    description = "Whether or not to enable logging of write operations in the storage account."
}
variable "storage_account_log_retention_policy_days" {
    type        = number
    default     = 3
    description = "Number of days to retain logs for the storage account."
}

# Web portal static web app config
variable "web_portal_branch" {
    type        = string
    default     = "main"
    description = "Branch of the repository to deploy for the web portal static web app."
}
variable "web_portal_repo_url" {
    type        = string
    default     = "https://github.com/Kressendo-Innovations/dancelife-web-portal"
    description = "URL of the repository for the web portal static web app."
}
variable "web_portal_sku_size" {
    type        = string
    default     = "Standard"
    description = "SKU size for the web portal static web app."
}
variable "web_portal_sku_tier" {
    type        = string
    default     = "Standard"
    description = "SKU tier for the web portal static web app."
}

// Alerts config
variable "ping_test_evaluation_frequency" {
    type        = string
    default     = "PT5M"
    description = "How often to evaluate ping test alerts."
}
variable "ping_test_window_duration" {
    type        = string
    default     = "PT15M"
    description = "Rolling time window used to evaluate ping test alerts."
}
variable "app_service_ping_test_consecutive_failures_alert_enabled" {
    type        = bool
    default     = false
    description = "Whether or not to enable the availability alert for consecutive failures of the App Service ping test."
}
variable "app_service_ping_test_consecutive_failures_alert_severity" {
    type        = number
    default     = 2
    description = "Severity for the App Service ping test consecutive failures alert."
}
variable "app_service_failed_requests_alert_enabled" {
    type        = bool
    default     = false
    description = "Whether or not to enable the failed-request-percentage alert for App Service."
}
variable "app_service_failed_requests_alert_threshold_percentage" {
    type        = number
    default     = 20
    description = "Failed request percentage threshold that triggers the App Service alert."
}
variable "app_service_failed_requests_alert_threshold_count" {
    type        = number
    default     = 5
    description = "Failed request count threshold that triggers the App Service alert."
}
variable "app_service_failed_requests_alert_evaluation_frequency" {
    type        = string
    default     = "PT15M"
    description = "How often to evaluate the failed request percentage alert."
}
variable "app_service_failed_requests_alert_window_duration" {
    type        = string
    default     = "PT30M"
    description = "Rolling time window used to calculate failed request percentage."
}
variable "app_service_failed_requests_alert_severity" {
    type        = number
    default     = 3
    description = "Severity for the App Service failed request percentage alert."
}
variable "app_service_cpu_alert_enabled" {
    type        = bool
    default     = false
    description = "Whether or not to enable the CPU percentage alert for the main App Service."
}
variable "app_service_cpu_alert_threshold_percentage" {
    type        = number
    default     = 68
    description = "CPU percentage threshold that triggers the main App Service alert."
}
variable "app_service_cpu_alert_window_size" {
    type        = string
    default     = "PT15M"
    description = "Rolling time window used to evaluate the main App Service CPU alert."
}
variable "app_service_cpu_alert_evaluation_frequency" {
    type        = string
    default     = "PT15M"
    description = "How often to evaluate the main App Service CPU alert."
}
variable "app_service_cpu_alert_severity" {
    type        = number
    default     = 3
    description = "Severity for the main App Service CPU alert."
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
variable "main_app_db_storage_percent_alert_window_size" {
    type        = string
    default     = "PT15M"
    description = "Rolling time window used to evaluate the main PostgreSQL storage percentage alert."
}
variable "main_app_db_storage_percent_alert_evaluation_frequency" {
    type        = string
    default     = "PT15M"
    description = "How often to evaluate the main PostgreSQL storage percentage alert."
}
variable "main_app_db_storage_percent_alert_severity" {
    type        = number
    default     = 3
    description = "Severity for the main PostgreSQL storage percentage alert."
}
variable "main_app_db_cpu_alert_enabled" {
    type        = bool
    default     = false
    description = "Whether or not to enable the CPU alert for the main PostgreSQL server."
}
variable "main_app_db_cpu_alert_threshold_percentage" {
    type        = number
    default     = 90
    description = "CPU percentage threshold that triggers the main PostgreSQL alert."
}
variable "main_app_db_cpu_alert_window_size" {
    type        = string
    default     = "PT15M"
    description = "Rolling time window used to evaluate the main PostgreSQL CPU alert."
}
variable "main_app_db_cpu_alert_evaluation_frequency" {
    type        = string
    default     = "PT5M"
    description = "How often to evaluate the main PostgreSQL CPU alert."
}
variable "main_app_db_cpu_alert_severity" {
    type        = number
    default     = 3
    description = "Severity for the main PostgreSQL CPU alert."
}
variable "main_app_db_active_connections_alert_enabled" {
    type        = bool
    default     = false
    description = "Whether or not to enable the active-connections alert for the main PostgreSQL server."
}
variable "main_app_db_active_connections_alert_threshold_percentage" {
    type        = number
    default     = 80
    description = "Active-connections percentage threshold that triggers the main PostgreSQL alert."
}
variable "main_app_db_active_connections_alert_evaluation_frequency" {
    type        = string
    default     = "PT5M"
    description = "How often to evaluate the main PostgreSQL active-connections alert."
}
variable "main_app_db_active_connections_alert_window_size" {
    type        = string
    default     = "PT30M"
    description = "Rolling time window used to evaluate the main PostgreSQL active-connections alert."
}
variable "main_app_db_active_connections_alert_severity" {
    type        = number
    default     = 3
    description = "Severity for the main PostgreSQL active-connections alert."
}