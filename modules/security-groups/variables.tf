# Security Groups Module Variables

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    ManagedBy = "terraform"
  }
}

variable "alb_ingress_rules" {
  description = "List of ingress rules for ALB security group"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    description = string
    cidr_blocks = string
  }))
  default = []
}

variable "ecs_ingress_rules" {
  description = "List of ingress rules for ECS security group"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    description = string
    cidr_blocks = string
  }))
  default = []
}

variable "rds_ingress_rules" {
  description = "List of ingress rules for RDS security group"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    description = string
    cidr_blocks = string
  }))
  default = []
} 