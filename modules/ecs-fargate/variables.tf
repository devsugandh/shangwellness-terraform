# ECS Fargate Module Variables

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "container_name" {
  description = "Name of the container"
  type        = string
}

variable "ecr_repo_uri" {
  description = "ECR repository URI"
  type        = string
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
  default     = 80
}

variable "cpu" {
  description = "CPU units for the task (1024 = 1 vCPU)"
  type        = number
  default     = 512
}

variable "memory" {
  description = "Memory for the task in MB"
  type        = number
  default     = 1024
}

variable "desired_count" {
  description = "Desired number of tasks"
  type        = number
  default     = 2
}

variable "min_tasks" {
  description = "Minimum number of tasks for auto scaling"
  type        = number
  default     = 1
}

variable "max_tasks" {
  description = "Maximum number of tasks for auto scaling"
  type        = number
  default     = 10
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs of the private subnets"
  type        = list(string)
}

variable "security_group_ids" {
  description = "IDs of the security groups"
  type        = list(string)
}

variable "target_group_arns" {
  description = "ARNs of the target groups"
  type        = list(string)
}

variable "listener_arns" {
  description = "ARNs of the ALB listeners"
  type        = list(string)
  default     = []
}

variable "enable_autoscaling" {
  description = "Enable auto scaling for the service"
  type        = bool
  default     = true
}

variable "cpu_threshold" {
  description = "CPU utilization threshold for auto scaling"
  type        = number
  default     = 70
}

variable "memory_threshold" {
  description = "Memory utilization threshold for auto scaling"
  type        = number
  default     = 80
}

variable "enable_blue_green_deployment" {
  description = "Enable blue/green deployment"
  type        = bool
  default     = true
}

variable "enable_canary_deployment" {
  description = "Enable canary deployment (overrides blue/green if both are enabled)"
  type        = bool
  default     = false
}

variable "deployment_controller_type" {
  description = "Type of deployment controller"
  type        = string
  default     = "CODE_DEPLOY"
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

variable "health_check_path" {
  description = "Health check path"
  type        = string
  default     = "/health"
}

variable "container_environment" {
  description = "Environment variables for the container"
  type        = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "task_definition_family" {
  description = "Family name for the ECS task definition"
  type        = string
  default     = ""
}

variable "service_name" {
  description = "Name for the ECS service"
  type        = string
  default     = ""
}

variable "container_secrets" {
  description = "Secrets for the container"
  type        = list(object({
    name      = string
    valueFrom = string
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