##########################################################
# Application Load Balancer
##########################################################
resource "aws_lb" "alb" {
  name               = "${var.alb_name}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.alb_security_groups
  subnets            = var.alb_public_subnet_ids

  enable_deletion_protection = true

  tags = {
    Terraform = "True"
    Project   = var.name 
    Service   = "load-balancer"
    environment = "${var.environment}"
  }
}

##########################################################
# Target Groups for Laravel Application
##########################################################
resource "aws_lb_target_group" "tg_443" {
  name        = var.target_group_1
  port        = 443
  protocol    = "HTTP"
  vpc_id      = var.alb_vpc_id
  target_type = "ip"

  health_check {
    path                = "/healthcheck"
    protocol            = "HTTP"
    healthy_threshold   = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
    timeout             = var.health_check_timeout
    interval            = var.health_check_interval
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "tg_8443" {
  name        = var.target_group_2
  port        = 8443
  protocol    = "HTTP"
  vpc_id      = var.alb_vpc_id
  target_type = "ip"

  health_check {
    path                = "/healthcheck"
    protocol            = "HTTP"
    healthy_threshold   = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
    timeout             = var.health_check_timeout
    interval            = var.health_check_interval
  }

  lifecycle {
    create_before_destroy = true
  }
}



##########################################################
# Listener Rules: Port-based routing for Laravel
##########################################################

# Listener for port 443
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_443.arn
  }
}

# Listener for port 8443
resource "aws_lb_listener" "custom_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 8443
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_8443.arn
  }
}

# HTTP Listener - Forward to port 443 target group
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_443.arn
  }
}