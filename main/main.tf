# Application Infrastructure
# This file contains the complete infrastructure setup for a scalable web application on AWS Fargate

# VPC Module
module "vpc" {
  source = "../modules/vpc"
  
  create_vpc = true
  name       = "${var.project_name}-${var.environment}"
  app        = "web-app"
  cidr       = var.vpc_cidr
  
  availability_zones = ["${var.aws_region}a", "${var.aws_region}b"]
  
  # Public subnets for ALB
  public_subnets = [
    cidrsubnet(var.vpc_cidr, 8, 1),  # 10.0.1.0/24
    cidrsubnet(var.vpc_cidr, 8, 2)   # 10.0.2.0/24
  ]
  public_subnet_names = [
    "${var.project_name}-${var.environment}-public-1",
    "${var.project_name}-${var.environment}-public-2"
  ]
  
  # Private subnets for ECS tasks
  private_subnets = [
    cidrsubnet(var.vpc_cidr, 8, 11), # 10.0.11.0/24
    cidrsubnet(var.vpc_cidr, 8, 12)  # 10.0.12.0/24
  ]
  private_subnet_names = [
    "${var.project_name}-${var.environment}-private-1",
    "${var.project_name}-${var.environment}-private-2"
  ]
  
  # Database subnets for Aurora
  database_subnets = [
    cidrsubnet(var.vpc_cidr, 8, 21), # 10.0.21.0/24
    cidrsubnet(var.vpc_cidr, 8, 22)  # 10.0.22.0/24
  ]
  database_subnet_names = [
    "${var.project_name}-${var.environment}-db-1",
    "${var.project_name}-${var.environment}-db-2"
  ]
  
  # NAT Gateway configuration
  single_nat_gateway = true
  
  # Create database subnet group
  create_database_subnet_group = true
  database_subnet_group_name   = "${var.project_name}-${var.environment}-db-subnet-group"
}

# Security Groups
module "security_groups" {
  source = "../modules/security-groups"
  
  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
  
  # ALB Security Group - allow inbound from internet
  alb_ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "HTTP from internet"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "HTTPS from internet"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 8443
      to_port     = 8443
      protocol    = "tcp"
      description = "Custom port from internet"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  
  # ECS Task Security Group - allow inbound only from ALB
  ecs_ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "HTTP from ALB"
      cidr_blocks = "0.0.0.0/0"  # Will be updated to ALB SG after creation
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "HTTPS from ALB"
      cidr_blocks = "0.0.0.0/0"  # Will be updated to ALB SG after creation
    },
    {
      from_port   = 8443
      to_port     = 8443
      protocol    = "tcp"
      description = "Custom port from ALB"
      cidr_blocks = "0.0.0.0/0"  # Will be updated to ALB SG after creation
    }
  ]
  
  # RDS Security Group - allow inbound only from ECS tasks
  rds_ingress_rules = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "MySQL from ECS tasks"
      cidr_blocks = "0.0.0.0/0"  # Will be updated to ECS SG after creation
    }
  ]
}

# Application Load Balancer
module "alb" {
  source = "../modules/load-balancer"
  
  alb_name = "${var.project_name}-${var.environment}-alb"
  name     = var.project_name
  environment = var.environment
  
  alb_security_groups    = [module.security_groups.alb_security_group_id]
  alb_public_subnet_ids  = module.vpc.public_subnets
  alb_vpc_id             = module.vpc.vpc_id
  
  # Target Groups for Laravel app (16 characters max for CodeDeploy compatibility)
  target_group_1 = "sw-prod-tg-443"
  target_group_2 = "sw-prod-tg-8443"
  
  # Enhanced health check configuration to prevent 503 errors
  health_check_path = var.health_check_path
  health_check_interval = 15        # More frequent checks during deployment
  health_check_timeout = 10         # Longer timeout for Laravel startup
  health_check_healthy_threshold = 2    # Require fewer successful checks
  health_check_unhealthy_threshold = 5  # Allow more failures before marking unhealthy
}

# ECR Repository
module "ecr" {
  source = "../modules/ecr"
  
  create_ecr_repository = true
  name = var.project_name
  ecr_repository_name = "${var.project_name}-${var.environment}"
  environment = var.environment
  ecr_retention_count = 5
}

# ECS Cluster and Fargate Service
module "ecs_fargate" {
  source = "../modules/ecs-fargate"
  
  project_name = var.project_name
  environment  = var.environment
  
  # ECS Cluster
  cluster_name = "${var.project_name}-${var.environment}-cluster"
  
  # VPC and Networking
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets
  security_group_ids = [module.security_groups.ecs_security_group_id]
  
  # Task Definition with database environment variables - NEW NAME
  container_name = var.container_name
  ecr_repo_uri   = var.ecr_repo_uri
  container_port = 80
  cpu            = 512  # 0.5 vCPU
  memory         = 1024 # 1 GB
  
  # Task definition and service names
  task_definition_family = "${var.project_name}-${var.environment}-task"
  service_name          = "${var.project_name}-${var.environment}-service"
  
  # Database environment variables
  container_environment = [
    {
      name  = "DB_NAME"
      value = "${var.project_name}_${var.environment}"
    },
    {
      name  = "APP_ENV"
      value = var.environment
    },
    {
      name  = "DB_USERNAME"
      value = "admin"
    },
    {
      name  = "DB_HOST"
      value = module.aurora.cluster_endpoint
    },
    {
      name  = "DB_PASSWORD"
      value = module.aurora.master_password
    }
  ]
  
  # Service Configuration
  desired_count = 2
  min_tasks     = 1
  max_tasks     = 10
  
  # Auto Scaling
  enable_autoscaling = true
  cpu_threshold      = 70
  memory_threshold   = 80
  
  # Load Balancer Integration
  target_group_arns = [
    module.alb.target_group_443_arn,
    module.alb.target_group_8443_arn
  ]
  
  # Listener ARNs for blue/green deployment
  listener_arns = [
    module.alb.listener_443_arn,
    module.alb.listener_8443_arn
  ]
  
  # Deployment Configuration - Enable Blue/Green with Canary
  enable_blue_green_deployment = true   # Enable Blue/Green deployment
  enable_canary_deployment     = true   # Enable canary deployment
  deployment_controller_type   = "CODE_DEPLOY"  # Use CodeDeploy for Blue/Green
  
  # Canary deployment configuration for zero-downtime deployments
  canary_deployment_config = {
    canary_percentage = 5   # Start with 5% of traffic to new version
    canary_interval   = 3   # 3 minutes between canary phases
    canary_timeout    = 5   # 5 minutes timeout for canary phase
  }
}

# CodeBuild Project
module "codebuild" {
  source = "../modules/codebuild"
  
  project_name = "${var.project_name}-${var.environment}"
  environment  = var.environment
  aws_region   = var.aws_region
  aws_account_id = var.aws_account_id
  
  # ECR Configuration
  ecr_repository_name = module.ecr.repository_name
  ecr_repository_uri  = module.ecr.ecr_repository_url
  ecr_repository_arn  = module.ecr.ecr_repository_arn
  
  # Container Configuration
  container_name = var.container_name
  
  # Buildspec Configuration (optional - will use default if not provided)
  buildspec_content = var.buildspec_content
  
  # Common tags
  common_tags = var.common_tags
}

# CodePipeline for ECS Deployment
module "codepipeline" {
  source = "../modules/codepipeline"
  
  project_name = var.project_name
  environment  = var.environment
  
  # Build and Deploy Configuration
  codebuild_project_name = module.codebuild.project_name
  codedeploy_application_name = module.ecs_fargate.code_deploy_application_name
  codedeploy_deployment_group_name = module.ecs_fargate.code_deploy_deployment_group_name
  
  # ECS Configuration for direct deployment
  ecs_cluster_name = "${var.project_name}-${var.environment}-cluster"
  ecs_service_name = "${var.project_name}-${var.environment}-service"
  
  # Common tags
  common_tags = var.common_tags
}

# Aurora Serverless v2
module "aurora" {
  source = "../modules/aurora-serverless"
  
  # Database Configuration
  cluster_identifier = "${var.project_name}-${var.environment}-aurora"
  engine             = "aurora-mysql"
  engine_version     = "8.0.mysql_aurora.3.04.1"
  
  # Serverless v2 Configuration
  serverlessv2_scaling_configuration = {
    min_capacity = 0.5
    max_capacity = 16.0
  }
  
  # Networking
  db_subnet_group_name      = module.vpc.database_subnet_group_name
  security_group_ids        = [module.security_groups.rds_security_group_id]
  
  # Database Settings
  database_name = "${var.project_name}_${var.environment}"
  master_username = "admin"
  
  # Backup and Maintenance
  backup_retention_period = 7
  preferred_backup_window = "03:00-04:00"
  preferred_maintenance_window = "sun:04:00-sun:05:00"
  
  # Security
  deletion_protection = true
  skip_final_snapshot = false
  
  # Common tags
  common_tags = var.common_tags
}

# Update security group rules after resources are created
resource "aws_security_group_rule" "ecs_from_alb" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = module.security_groups.alb_security_group_id
  security_group_id        = module.security_groups.ecs_security_group_id
  description              = "HTTP from ALB"
}

resource "aws_security_group_rule" "ecs_from_alb_https" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = module.security_groups.alb_security_group_id
  security_group_id        = module.security_groups.ecs_security_group_id
  description              = "HTTPS from ALB"
}

resource "aws_security_group_rule" "ecs_from_alb_custom" {
  type                     = "ingress"
  from_port                = 8443
  to_port                  = 8443
  protocol                 = "tcp"
  source_security_group_id = module.security_groups.alb_security_group_id
  security_group_id        = module.security_groups.ecs_security_group_id
  description              = "Custom port from ALB"
}

resource "aws_security_group_rule" "rds_from_ecs" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = module.security_groups.ecs_security_group_id
  security_group_id        = module.security_groups.rds_security_group_id
  description              = "MySQL from ECS tasks"
}