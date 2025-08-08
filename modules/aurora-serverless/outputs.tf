# Aurora Serverless v2 Module Outputs

output "cluster_id" {
  description = "ID of the Aurora cluster"
  value       = aws_rds_cluster.aurora.id
}

output "cluster_arn" {
  description = "ARN of the Aurora cluster"
  value       = aws_rds_cluster.aurora.arn
}

output "cluster_identifier" {
  description = "Identifier of the Aurora cluster"
  value       = aws_rds_cluster.aurora.cluster_identifier
}

output "cluster_endpoint" {
  description = "Writer endpoint of the Aurora cluster"
  value       = aws_rds_cluster.aurora.endpoint
}

output "cluster_reader_endpoint" {
  description = "Reader endpoint of the Aurora cluster"
  value       = aws_rds_cluster.aurora.reader_endpoint
}

output "cluster_port" {
  description = "Port of the Aurora cluster"
  value       = aws_rds_cluster.aurora.port
}

output "database_name" {
  description = "Name of the database"
  value       = aws_rds_cluster.aurora.database_name
}

output "master_username" {
  description = "Master username"
  value       = aws_rds_cluster.aurora.master_username
}

output "master_password_secret_arn" {
  description = "ARN of the master password secret"
  value       = aws_secretsmanager_secret.aurora_master_password.arn
}

output "master_password" {
  description = "Master password for the database"
  value       = random_password.master_password.result
  sensitive   = true
}

output "instance_id" {
  description = "ID of the Aurora instance"
  value       = aws_rds_cluster_instance.aurora.id
}

output "instance_arn" {
  description = "ARN of the Aurora instance"
  value       = aws_rds_cluster_instance.aurora.arn
}

output "instance_endpoint" {
  description = "Endpoint of the Aurora instance"
  value       = aws_rds_cluster_instance.aurora.endpoint
}

output "cluster_parameter_group_id" {
  description = "ID of the cluster parameter group"
  value       = aws_rds_cluster_parameter_group.aurora.id
}

output "instance_parameter_group_id" {
  description = "ID of the instance parameter group"
  value       = aws_db_parameter_group.aurora.id
}

output "connection_string" {
  description = "Connection string for the database"
  value       = "mysql://${aws_rds_cluster.aurora.master_username}:${random_password.master_password.result}@${aws_rds_cluster.aurora.endpoint}:${aws_rds_cluster.aurora.port}/${aws_rds_cluster.aurora.database_name}"
  sensitive   = true
} 