output "alb_id" {
  description = "ID of the Application Load Balancer"
  value = aws_lb.alb.id
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value = aws_lb.alb.arn
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value = aws_lb.alb.dns_name
}

output "target_group_443_arn" {
  description = "ARN of the target group for port 443"
  value = aws_lb_target_group.tg_443.arn
}

output "target_group_8443_arn" {
  description = "ARN of the target group for port 8443"
  value = aws_lb_target_group.tg_8443.arn
}

output "listener_443_arn" {
  description = "ARN of the listener for port 443"
  value = aws_lb_listener.https_listener.arn
}

output "listener_8443_arn" {
  description = "ARN of the listener for port 8443"
  value = aws_lb_listener.custom_listener.arn
}

output "listener_80_arn" {
  description = "ARN of the listener for port 80 (forward)"
  value = aws_lb_listener.http_listener.arn
}