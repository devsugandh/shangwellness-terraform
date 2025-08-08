# ECS Fargate Module Outputs

output "cluster_id" {
  description = "ID of the ECS cluster"
  value       = aws_ecs_cluster.main.id
}

output "cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = aws_ecs_cluster.main.arn
}

output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "service_id" {
  description = "ID of the ECS service"
  value       = aws_ecs_service.main.id
}

output "service_arn" {
  description = "ARN of the ECS service"
  value       = aws_ecs_service.main.id
}

output "service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.main.name
}

output "task_definition_arn" {
  description = "ARN of the ECS task definition"
  value       = aws_ecs_task_definition.main.arn
}

output "task_definition_family" {
  description = "Family of the ECS task definition"
  value       = aws_ecs_task_definition.main.family
}

output "task_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  value       = aws_iam_role.ecs_task_execution.arn
}

output "task_role_arn" {
  description = "ARN of the ECS task role"
  value       = aws_iam_role.ecs_task.arn
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.ecs.name
}

output "autoscaling_target_id" {
  description = "ID of the auto scaling target"
  value       = var.enable_autoscaling ? aws_appautoscaling_target.ecs_target[0].id : null
}

output "autoscaling_policy_arns" {
  description = "ARNs of the auto scaling policies"
  value = var.enable_autoscaling ? [
    aws_appautoscaling_policy.ecs_cpu[0].arn,
    aws_appautoscaling_policy.ecs_memory[0].arn
  ] : []
}

output "code_deploy_application_name" {
  description = "Name of the CodeDeploy application"
  value       = (var.enable_blue_green_deployment || var.enable_canary_deployment) ? aws_codedeploy_app.ecs[0].name : null
}

output "code_deploy_deployment_group_name" {
  description = "Name of the CodeDeploy deployment group"
  value       = (var.enable_blue_green_deployment || var.enable_canary_deployment) ? aws_codedeploy_deployment_group.ecs[0].deployment_group_name : null
}

output "code_deploy_service_role_arn" {
  description = "ARN of the CodeDeploy service role"
  value       = (var.enable_blue_green_deployment || var.enable_canary_deployment) ? aws_iam_role.codedeploy_service_role[0].arn : null
}

output "deployment_type" {
  description = "Type of deployment being used"
  value       = var.enable_canary_deployment ? "canary" : (var.enable_blue_green_deployment ? "blue-green" : "none")
}

output "deployment_config_name" {
  description = "Name of the deployment configuration"
  value       = (var.enable_blue_green_deployment || var.enable_canary_deployment) ? aws_codedeploy_deployment_group.ecs[0].deployment_config_name : null
} 