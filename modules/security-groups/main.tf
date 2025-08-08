# Security Groups Module
# This module creates security groups for ALB, ECS tasks, and RDS

# ALB Security Group
resource "aws_security_group" "alb" {
  name_prefix = "${var.project_name}-${var.environment}-alb-"
  description = "Security group for Application Load Balancer"
  vpc_id      = var.vpc_id

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-alb-sg"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# ECS Tasks Security Group
resource "aws_security_group" "ecs" {
  name_prefix = "${var.project_name}-${var.environment}-ecs-"
  description = "Security group for ECS tasks"
  vpc_id      = var.vpc_id

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-ecs-sg"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# RDS Security Group
resource "aws_security_group" "rds" {
  name_prefix = "${var.project_name}-${var.environment}-rds-"
  description = "Security group for Aurora RDS"
  vpc_id      = var.vpc_id

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-rds-sg"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# ALB Ingress Rules
resource "aws_security_group_rule" "alb_ingress" {
  count = length(var.alb_ingress_rules)

  type              = "ingress"
  from_port         = var.alb_ingress_rules[count.index].from_port
  to_port           = var.alb_ingress_rules[count.index].to_port
  protocol          = var.alb_ingress_rules[count.index].protocol
  cidr_blocks       = [var.alb_ingress_rules[count.index].cidr_blocks]
  description       = var.alb_ingress_rules[count.index].description
  security_group_id = aws_security_group.alb.id
}

# ECS Ingress Rules
resource "aws_security_group_rule" "ecs_ingress" {
  count = length(var.ecs_ingress_rules)

  type              = "ingress"
  from_port         = var.ecs_ingress_rules[count.index].from_port
  to_port           = var.ecs_ingress_rules[count.index].to_port
  protocol          = var.ecs_ingress_rules[count.index].protocol
  cidr_blocks       = [var.ecs_ingress_rules[count.index].cidr_blocks]
  description       = var.ecs_ingress_rules[count.index].description
  security_group_id = aws_security_group.ecs.id
}

# RDS Ingress Rules
resource "aws_security_group_rule" "rds_ingress" {
  count = length(var.rds_ingress_rules)

  type              = "ingress"
  from_port         = var.rds_ingress_rules[count.index].from_port
  to_port           = var.rds_ingress_rules[count.index].to_port
  protocol          = var.rds_ingress_rules[count.index].protocol
  cidr_blocks       = [var.rds_ingress_rules[count.index].cidr_blocks]
  description       = var.rds_ingress_rules[count.index].description
  security_group_id = aws_security_group.rds.id
} 