# Application Variables
# This file contains all variables needed for the web application infrastructure

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "shangwellness"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "ap-south-1"
}

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
  default     = "669097061043"
}

variable "container_name" {
  description = "Name of the application container"
  type        = string
  default     = "web-app"
}

variable "ecr_repo_uri" {
  description = "ECR repository URI for the application"
  type        = string
  default     = "669097061043.dkr.ecr.ap-south-1.amazonaws.com/web-app"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# Auto Scaling Configuration
variable "autoscaling_cpu_threshold" {
  description = "CPU utilization threshold for auto scaling"
  type        = number
  default     = 70
}

variable "autoscaling_memory_threshold" {
  description = "Memory utilization threshold for auto scaling"
  type        = number
  default     = 80
}

variable "autoscaling_min_tasks" {
  description = "Minimum number of ECS tasks"
  type        = number
  default     = 1
}

variable "autoscaling_max_tasks" {
  description = "Maximum number of ECS tasks"
  type        = number
  default     = 10
}

variable "autoscaling_desired_tasks" {
  description = "Desired number of ECS tasks"
  type        = number
  default     = 2
}

# ECS Task Configuration
variable "ecs_task_cpu" {
  description = "CPU units for ECS task (1024 = 1 vCPU)"
  type        = number
  default     = 512  # 0.5 vCPU
}

variable "ecs_task_memory" {
  description = "Memory for ECS task in MB"
  type        = number
  default     = 1024 # 1 GB
}

variable "ecs_container_port" {
  description = "Port the application listens on"
  type        = number
  default     = 80
}

# Aurora Configuration
variable "aurora_min_capacity" {
  description = "Minimum Aurora Serverless v2 capacity"
  type        = number
  default     = 0.5
}

variable "aurora_max_capacity" {
  description = "Maximum Aurora Serverless v2 capacity"
  type        = number
  default     = 16.0
}

variable "aurora_backup_retention" {
  description = "Number of days to retain Aurora backups"
  type        = number
  default     = 7
}

# Deployment Configuration
variable "enable_canary_deployment" {
  description = "Enable canary deployment (overrides blue/green if both are enabled)"
  type        = bool
  default     = false
}

variable "enable_blue_green_deployment" {
  description = "Enable blue/green deployment"
  type        = bool
  default     = false
}

variable "canary_deployment_config" {
  description = "Configuration for canary deployment"
  type = object({
    canary_percentage = number
    canary_interval   = number
    canary_timeout    = number
  })
  default = {
    canary_percentage = 10
    canary_interval   = 5
    canary_timeout    = 10
  }
}

# Health Check Configuration
variable "health_check_path" {
  description = "Path for health checks"
  type        = string
  default     = "/health"
}

variable "health_check_interval" {
  description = "Health check interval in seconds"
  type        = number
  default     = 30
}

variable "health_check_timeout" {
  description = "Health check timeout in seconds"
  type        = number
  default     = 5
}

variable "health_check_healthy_threshold" {
  description = "Number of consecutive successful health checks"
  type        = number
  default     = 3
}

variable "health_check_unhealthy_threshold" {
  description = "Number of consecutive failed health checks"
  type        = number
  default     = 3
}

# Tags
# CI/CD Pipeline Variables (Source will be configured manually in AWS Console)

variable "buildspec_content" {
  description = "Custom buildspec content (optional - will use default if not provided)"
  type        = string
  default     = ""
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Project     = "web-app"
    Environment = "prod"
    ManagedBy   = "terraform"
    Application = "web"
    Owner       = "devops-team"
  }
} 