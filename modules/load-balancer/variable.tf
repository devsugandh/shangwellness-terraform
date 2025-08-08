variable "name" {
  description = "Name of the project"
  type        = string
  default     = null
}

variable "app" {
  description = "Application name"
  type        = string
  default     = null
}

variable "alb_name" {
  description = "Name of the Application Load Balancer"
  type        = string
}

variable "alb_vpc_id" {
  description = "ID of the VPC for the ALB"
  type        = string
}

variable "alb_public_subnet_ids" {
  description = "IDs of the public subnets for the ALB"
  type        = list(string)
  default     = []
}

variable "alb_security_groups" {
  description = "Security groups for the ALB"
  type        = list(string)
  default     = []
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "target_group_1" {
  description = "Name of the first target group (port 443)"
  type        = string
}

variable "target_group_2" {
  description = "Name of the second target group (port 8443)"
  type        = string
}

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