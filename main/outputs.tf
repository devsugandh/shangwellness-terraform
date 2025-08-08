# Laravel Application Outputs
# This file contains all outputs from the Laravel application infrastructure

# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnets
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnets
}

output "database_subnet_ids" {
  description = "IDs of the database subnets"
  value       = module.vpc.database_subnets
}

output "database_subnet_group_name" {
  description = "Name of the database subnet group"
  value       = module.vpc.database_subnet_group_name
}

# Security Group Outputs
output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = module.security_groups.alb_security_group_id
}

output "ecs_security_group_id" {
  description = "ID of the ECS security group"
  value       = module.security_groups.ecs_security_group_id
}

output "rds_security_group_id" {
  description = "ID of the RDS security group"
  value       = module.security_groups.rds_security_group_id
}

# Load Balancer Outputs
output "alb_id" {
  description = "ID of the Application Load Balancer"
  value       = module.alb.alb_id
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = module.alb.alb_arn
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "target_group_443_arn" {
  description = "ARN of the target group for port 443"
  value       = module.alb.target_group_443_arn
}

output "target_group_8443_arn" {
  description = "ARN of the target group for port 8443"
  value       = module.alb.target_group_8443_arn
}

# ECR Outputs
output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = module.ecr.ecr_repository_url
}

output "ecr_repository_arn" {
  description = "ARN of the ECR repository"
  value       = module.ecr.ecr_repository_arn
}

# ECS Outputs
output "ecs_cluster_id" {
  description = "ID of the ECS cluster"
  value       = module.ecs_fargate.cluster_id
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = module.ecs_fargate.cluster_arn
}

output "ecs_service_id" {
  description = "ID of the ECS service"
  value       = module.ecs_fargate.service_id
}

output "ecs_service_arn" {
  description = "ARN of the ECS service"
  value       = module.ecs_fargate.service_arn
}

output "ecs_task_definition_arn" {
  description = "ARN of the ECS task definition"
  value       = module.ecs_fargate.task_definition_arn
}

output "ecs_task_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  value       = module.ecs_fargate.task_execution_role_arn
}

output "ecs_task_role_arn" {
  description = "ARN of the ECS task role"
  value       = module.ecs_fargate.task_role_arn
}

# Aurora Outputs
output "aurora_cluster_id" {
  description = "ID of the Aurora cluster"
  value       = module.aurora.cluster_id
}

output "aurora_cluster_arn" {
  description = "ARN of the Aurora cluster"
  value       = module.aurora.cluster_arn
}

output "aurora_cluster_endpoint" {
  description = "Writer endpoint of the Aurora cluster"
  value       = module.aurora.cluster_endpoint
}

output "aurora_cluster_reader_endpoint" {
  description = "Reader endpoint of the Aurora cluster"
  value       = module.aurora.cluster_reader_endpoint
}

output "aurora_database_name" {
  description = "Name of the Aurora database"
  value       = module.aurora.database_name
}

# Auto Scaling Outputs
output "ecs_autoscaling_target_id" {
  description = "ID of the ECS auto scaling target"
  value       = module.ecs_fargate.autoscaling_target_id
}

output "ecs_autoscaling_policy_arns" {
  description = "ARNs of the ECS auto scaling policies"
  value       = module.ecs_fargate.autoscaling_policy_arns
}

# CI/CD Integration Outputs
output "code_deploy_application_name" {
  description = "Name of the CodeDeploy application for deployment"
  value       = module.ecs_fargate.code_deploy_application_name
}

output "code_deploy_deployment_group_name" {
  description = "Name of the CodeDeploy deployment group"
  value       = module.ecs_fargate.code_deploy_deployment_group_name
}

output "deployment_type" {
  description = "Type of deployment being used (blue-green or canary)"
  value       = module.ecs_fargate.deployment_type
}

output "deployment_config_name" {
  description = "Name of the deployment configuration"
  value       = module.ecs_fargate.deployment_config_name
}

# Monitoring and Logging Outputs
output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group for ECS tasks"
  value       = module.ecs_fargate.cloudwatch_log_group_name
}

# Network Configuration for CI/CD
output "vpc_config" {
  description = "VPC configuration for CI/CD pipelines"
  value = {
    vpc_id             = module.vpc.vpc_id
    private_subnet_ids = module.vpc.private_subnets
    security_group_ids = [module.security_groups.ecs_security_group_id]
  }
}

# Application Endpoints
output "application_endpoint" {
  description = "Main application endpoint"
  value       = "http://${module.alb.alb_dns_name}"
}

output "health_check_endpoint" {
  description = "Health check endpoint"
  value       = "http://${module.alb.alb_dns_name}${var.health_check_path}"
}

# Resource Summary
# CI/CD Pipeline Outputs
output "codebuild_project_name" {
  description = "Name of the CodeBuild project"
  value       = module.codebuild.project_name
}

output "codebuild_project_arn" {
  description = "ARN of the CodeBuild project"
  value       = module.codebuild.project_arn
}

output "codepipeline_name" {
  description = "Name of the CodePipeline"
  value       = module.codepipeline.pipeline_name
}

output "codepipeline_arn" {
  description = "ARN of the CodePipeline"
  value       = module.codepipeline.pipeline_arn
}

output "artifact_bucket_name" {
  description = "Name of the S3 bucket used for pipeline artifacts"
  value       = module.codepipeline.artifact_bucket_name
}

output "resource_summary" {
  description = "Summary of all created resources"
  value = {
    project_name    = var.project_name
    environment     = var.environment
    aws_region      = var.aws_region
    vpc_id          = module.vpc.vpc_id
    alb_dns_name    = module.alb.alb_dns_name
    ecs_cluster_id  = module.ecs_fargate.cluster_id
    aurora_endpoint = module.aurora.cluster_endpoint
    ecr_repository  = module.ecr.ecr_repository_url
    codebuild_project = module.codebuild.project_name
    codepipeline_name = module.codepipeline.pipeline_name
  }
} 