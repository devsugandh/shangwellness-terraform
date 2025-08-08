# Aurora Serverless v2 Module
# This module creates an Aurora MySQL cluster with serverless v2 configuration

# Random password for master user
resource "random_password" "master_password" {
  length  = 16
  special = false
}

# Store master password in Secrets Manager
resource "aws_secretsmanager_secret" "aurora_master_password" {
  name = "${var.cluster_identifier}-master-password"
  
  tags = merge(
    var.common_tags,
    {
      Name = "${var.cluster_identifier}-master-password"
    }
  )
}

resource "aws_secretsmanager_secret_version" "aurora_master_password" {
  secret_id     = aws_secretsmanager_secret.aurora_master_password.id
  secret_string = random_password.master_password.result
}

# Aurora Cluster
resource "aws_rds_cluster" "aurora" {
  cluster_identifier     = var.cluster_identifier
  engine                = var.engine
  engine_version        = var.engine_version
  engine_mode           = "provisioned"
  database_name         = var.database_name
  master_username       = var.master_username
  master_password       = random_password.master_password.result
  skip_final_snapshot   = var.skip_final_snapshot
  deletion_protection   = var.deletion_protection

  # Serverless v2 configuration
  serverlessv2_scaling_configuration {
    min_capacity = var.serverlessv2_scaling_configuration.min_capacity
    max_capacity = var.serverlessv2_scaling_configuration.max_capacity
  }

  # Backup configuration
  backup_retention_period   = var.backup_retention_period
  preferred_backup_window   = var.preferred_backup_window
  preferred_maintenance_window = var.preferred_maintenance_window

  # Network configuration
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = var.security_group_ids

  # Storage configuration
  storage_encrypted = true

  # Monitoring
  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]

  tags = merge(
    var.common_tags,
    {
      Name = var.cluster_identifier
    }
  )
}

# RDS Monitoring Role
resource "aws_iam_role" "rds_monitoring_role" {
  count = var.monitoring_interval > 0 ? 1 : 0
  name  = "${var.cluster_identifier}-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  # managed_policy_arns is deprecated, using policy attachment instead

  tags = merge(
    var.common_tags,
    {
      Name = "${var.cluster_identifier}-monitoring-role"
    }
  )
}

# Attach RDS Enhanced Monitoring Policy
resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  count      = var.monitoring_interval > 0 ? 1 : 0
  role       = aws_iam_role.rds_monitoring_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# Aurora Instance
resource "aws_rds_cluster_instance" "aurora" {
  identifier         = "${var.cluster_identifier}-instance-1"
  cluster_identifier = aws_rds_cluster.aurora.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.aurora.engine
  engine_version     = aws_rds_cluster.aurora.engine_version

  # Performance Insights
  performance_insights_enabled = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_retention_period

  # Monitoring
  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = var.monitoring_interval > 0 ? aws_iam_role.rds_monitoring_role[0].arn : null

  tags = merge(
    var.common_tags,
    {
      Name = "${var.cluster_identifier}-instance-1"
    }
  )

  depends_on = [aws_rds_cluster.aurora]
}

# Parameter Group for Aurora
resource "aws_rds_cluster_parameter_group" "aurora" {
  family = "aurora-mysql8.0"
  name   = "${var.cluster_identifier}-cluster-params"

  dynamic "parameter" {
    for_each = var.cluster_parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.cluster_identifier}-cluster-params"
    }
  )
}



# Instance Parameter Group
resource "aws_db_parameter_group" "aurora" {
  family = "aurora-mysql8.0"
  name   = "${var.cluster_identifier}-instance-params"

  dynamic "parameter" {
    for_each = var.instance_parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.cluster_identifier}-instance-params"
    }
  )
}

 