# Application Terraform Variables
# This file contains the specific values for the web application deployment

# Project Configuration
project_name = "shangwellness"
environment  = "prod"
aws_region   = "ap-south-1"
aws_account_id = "669097061043"

# Container Configuration
container_name = "web-app"
ecr_repo_uri   = "669097061043.dkr.ecr.ap-south-1.amazonaws.com/web-app"

# VPC Configuration
vpc_cidr = "10.0.0.0/16"

# Auto Scaling Configuration
autoscaling_cpu_threshold = 70
autoscaling_memory_threshold = 80
autoscaling_min_tasks = 1
autoscaling_max_tasks = 10
autoscaling_desired_tasks = 2

# ECS Task Configuration
ecs_task_cpu = 512      # 0.5 vCPU
ecs_task_memory = 1024  # 1 GB
ecs_container_port = 80

# Aurora Configuration
aurora_min_capacity = 0.5
aurora_max_capacity = 16.0
aurora_backup_retention = 7

# Deployment Configuration - Using Canary for zero-downtime deployments
enable_canary_deployment = true   # Enabled to avoid 503 downtime
enable_blue_green_deployment = false  # Disabled to prevent instant traffic switch
canary_deployment_config = {
  canary_percentage = 5   # Start with 5% of traffic to new version
  canary_interval   = 3   # 3 minutes between canary phases
  canary_timeout    = 5   # 5 minutes timeout for canary phase
}

# Enhanced Health Check Configuration to prevent 503 errors
health_check_path = "/health"
health_check_interval = 15        # More frequent checks during deployment
health_check_timeout = 10         # Longer timeout for application startup
health_check_healthy_threshold = 2    # Require fewer successful checks
health_check_unhealthy_threshold = 5  # Allow more failures before marking unhealthy

# CI/CD Pipeline Configuration
# Source stage will be configured manually in AWS Console
buildspec_content = ""  # Leave empty to use default buildspec

# Common Tags
common_tags = {
  Project     = "web-app"
  Environment = "prod"
  ManagedBy   = "terraform"
  Application = "web"
  Owner       = "devops-team"
} 