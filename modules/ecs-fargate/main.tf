# ECS Fargate Module
# This module creates an ECS cluster with Fargate tasks, auto-scaling, and blue/green deployment

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = var.cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = merge(
    var.common_tags,
    {
      Name = var.cluster_name
    }
  )
}

# CloudWatch Log Group for ECS tasks
resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.environment}/${var.container_name}"
  retention_in_days = 14

  tags = merge(
    var.common_tags,
    {
      Name = "/ecs/${var.environment}/${var.container_name}"
    }
  )
}

# ECS Task Execution Role
resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.project_name}-${var.environment}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-ecs-task-execution-role"
    }
  )
}

# Attach ECS Task Execution Role Policy
resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Task Role
resource "aws_iam_role" "ecs_task" {
  name = "${var.project_name}-${var.environment}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-ecs-task-role"
    }
  )
}

# ECS Task Definition
resource "aws_ecs_task_definition" "main" {
  family                   = var.task_definition_family != "" ? var.task_definition_family : "${var.project_name}-${var.environment}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name  = "shangwellness-app"
              image = "669097061043.dkr.ecr.ap-south-1.amazonaws.com/shangwellness-prod:latest"
      portMappings = [
        {
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ]
      environment = var.container_environment
      secrets     = var.container_secrets
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs.name
          awslogs-region        = "ap-south-1"
          awslogs-stream-prefix = "ecs"
        }
      }
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:${var.container_port}/healthcheck || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
    }
  ])

  tags = var.common_tags
}

# ECS Service
resource "aws_ecs_service" "main" {
  name            = var.service_name != "" ? var.service_name : "${var.project_name}-${var.environment}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"
  platform_version = "1.4.0"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = false
  }

  # Load balancer configuration (minimal required for CodeDeploy)
  dynamic "load_balancer" {
    for_each = var.target_group_arns
    content {
      target_group_arn = load_balancer.value
      container_name   = "shangwellness-app"
      container_port   = var.container_port
    }
  }

  # Deployment controller for CodeDeploy Blue/Green
  deployment_controller {
    type = var.deployment_controller_type
  }

  # Auto scaling is handled by Application Auto Scaling resources below

  depends_on = [aws_ecs_cluster.main, aws_ecs_task_definition.main]

  tags = var.common_tags
}

# Application Auto Scaling Target
resource "aws_appautoscaling_target" "ecs_target" {
  count              = var.enable_autoscaling ? 1 : 0
  max_capacity       = var.max_tasks
  min_capacity       = var.min_tasks
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.main.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# CPU Auto Scaling Policy
resource "aws_appautoscaling_policy" "ecs_cpu" {
  count              = var.enable_autoscaling ? 1 : 0
  name               = "${var.project_name}-${var.environment}-cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = var.cpu_threshold
  }
}

# Memory Auto Scaling Policy
resource "aws_appautoscaling_policy" "ecs_memory" {
  count              = var.enable_autoscaling ? 1 : 0
  name               = "${var.project_name}-${var.environment}-memory-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value = var.memory_threshold
  }
}

# CodeDeploy Application for Blue/Green or Canary Deployment
resource "aws_codedeploy_app" "ecs" {
  count            = var.enable_blue_green_deployment || var.enable_canary_deployment ? 1 : 0
  compute_platform = "ECS"
  name             = "${var.project_name}-${var.environment}-codedeploy"
}

# CodeDeploy Deployment Group
resource "aws_codedeploy_deployment_group" "ecs" {
  count               = var.enable_blue_green_deployment || var.enable_canary_deployment ? 1 : 0
  app_name            = aws_codedeploy_app.ecs[0].name
  deployment_group_name = "${var.project_name}-${var.environment}-deployment-group"
  deployment_config_name = "CodeDeployDefault.ECSCanary10Percent5Minutes"
  service_role_arn    = aws_iam_role.codedeploy_service_role[0].arn

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE", "DEPLOYMENT_STOP_ON_ALARM"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  dynamic "ecs_service" {
    for_each = var.enable_blue_green_deployment || var.enable_canary_deployment ? [1] : []
    content {
      cluster_name = aws_ecs_cluster.main.name
      service_name = aws_ecs_service.main.name
    }
  }

  dynamic "load_balancer_info" {
    for_each = var.enable_blue_green_deployment || var.enable_canary_deployment ? [1] : []
    content {
      target_group_pair_info {
        prod_traffic_route {
          listener_arns = [var.listener_arns[0]]
        }

        target_group {
          name = var.target_group_arns[0]
        }

        target_group {
          name = var.target_group_arns[1]
        }
      }
    }
  }
}

# CodeDeploy Service Role
resource "aws_iam_role" "codedeploy_service_role" {
  count = var.enable_blue_green_deployment || var.enable_canary_deployment ? 1 : 0
  name  = "${var.project_name}-${var.environment}-codedeploy-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codedeploy.amazonaws.com"
        }
      }
    ]
  })
}

# Attach CodeDeploy Service Role Policy
resource "aws_iam_role_policy_attachment" "codedeploy_service_role" {
  count      = var.enable_blue_green_deployment || var.enable_canary_deployment ? 1 : 0
  role       = aws_iam_role.codedeploy_service_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
} 