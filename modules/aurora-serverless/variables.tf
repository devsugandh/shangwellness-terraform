# Aurora Serverless v2 Module Variables

variable "cluster_identifier" {
  description = "Identifier for the Aurora cluster"
  type        = string
}

variable "engine" {
  description = "Aurora engine type"
  type        = string
  default     = "aurora-mysql"
}

variable "engine_version" {
  description = "Aurora engine version"
  type        = string
  default     = "8.0.mysql_aurora.3.04.1"
}

variable "database_name" {
  description = "Name of the database to create"
  type        = string
}

variable "master_username" {
  description = "Master username for the database"
  type        = string
  default     = "admin"
}

variable "serverlessv2_scaling_configuration" {
  description = "Serverless v2 scaling configuration"
  type = object({
    min_capacity = number
    max_capacity = number
  })
  default = {
    min_capacity = 0.5
    max_capacity = 16.0
  }
}

variable "backup_retention_period" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7
}

variable "preferred_backup_window" {
  description = "Preferred backup window"
  type        = string
  default     = "03:00-04:00"
}

variable "preferred_maintenance_window" {
  description = "Preferred maintenance window"
  type        = string
  default     = "sun:04:00-sun:05:00"
}

variable "db_subnet_group_name" {
  description = "Name of the DB subnet group"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot when deleting"
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = true
}

variable "performance_insights_enabled" {
  description = "Enable Performance Insights"
  type        = bool
  default     = true
}

variable "performance_insights_retention_period" {
  description = "Performance Insights retention period in days"
  type        = number
  default     = 7
}

variable "monitoring_interval" {
  description = "Monitoring interval in seconds"
  type        = number
  default     = 60
}

variable "monitoring_role_arn" {
  description = "ARN of the monitoring role"
  type        = string
  default     = null
}

variable "cluster_parameters" {
  description = "Cluster parameter group parameters"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "instance_parameters" {
  description = "Instance parameter group parameters"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    ManagedBy = "terraform"
  }
} 