# CodePipeline Module Variables

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

# Source-related variables removed - will be configured manually in AWS Console

variable "codebuild_project_name" {
  description = "Name of the CodeBuild project"
  type        = string
}

variable "codedeploy_application_name" {
  description = "Name of the CodeDeploy application"
  type        = string
}

variable "codedeploy_deployment_group_name" {
  description = "Name of the CodeDeploy deployment group"
  type        = string
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "ecs_service_name" {
  description = "Name of the ECS service"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
} 