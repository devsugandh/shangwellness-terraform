# 🏗️ Infrastructure Overview - Shangwellness Production

## 📋 Architecture Summary

The Shangwellness production infrastructure is built on AWS using a modern, scalable, and highly available architecture with Blue/Green deployment strategy for zero-downtime deployments.

## 🏛️ High-Level Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Internet      │    │   Route 53      │    │   CloudFront    │
│   Users         │───▶│   (DNS)         │───▶│   (CDN)         │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                                        │
                                                        ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   CodePipeline  │    │   CodeBuild     │    │   CodeDeploy    │
│   (CI/CD)       │───▶│   (Build)       │───▶│   (Deploy)      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                                        │
                                                        ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Application   │    │   Load Balancer │    │   ECS Fargate   │
│   Load Balancer │◀───│   (ALB)         │◀───│   (Containers)  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                                        │
                                                        ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Aurora MySQL  │    │   Secrets       │    │   CloudWatch    │
│   (Database)    │◀───│   Manager       │◀───│   (Monitoring)  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🧩 Infrastructure Components

### 1. 🚀 Compute Layer - ECS Fargate

#### ECS Cluster
- **Name**: `shangwellness-prod-cluster`
- **Type**: Fargate (Serverless)
- **Region**: `ap-south-1` (Mumbai)
- **Auto Scaling**: Enabled

#### ECS Service
- **Name**: `shangwellness-prod-service`
- **Desired Count**: 2 (for high availability)
- **Deployment Controller**: CodeDeploy
- **Health Check**: `/healthcheck` endpoint

#### Container Configuration
- **Container Name**: `shangwellness-app`
- **Image**: `669097061043.dkr.ecr.ap-south-1.amazonaws.com/shangwellness-prod:latest`
- **CPU**: 512 units (0.5 vCPU)
- **Memory**: 1024 MB (1 GB)
- **Port**: 80 (HTTP)

### 2. 🗄️ Database Layer - Aurora MySQL

#### RDS Cluster
- **Engine**: Aurora MySQL 8.0
- **Cluster**: `shangwellness-prod-aurora`
- **Instance Type**: Serverless v2
- **Storage**: Auto-scaling
- **Backup**: Automated daily backups

#### Database Configuration
- **Database Name**: `shangwellness_prod`
- **Username**: `admin`
- **Password**: Managed by Secrets Manager
- **Endpoint**: `shangwellness-prod-aurora.cluster-cj8iwom2850v.ap-south-1.rds.amazonaws.com`

### 3. 🌐 Network Layer - VPC & Load Balancer

#### VPC Configuration
- **CIDR**: `10.0.0.0/16`
- **Availability Zones**: 2 (ap-south-1a, ap-south-1b)
- **Subnets**:
  - **Public**: 2 subnets (for ALB)
  - **Private**: 2 subnets (for ECS)
  - **Database**: 2 subnets (for RDS)

#### Load Balancer
- **Type**: Application Load Balancer (ALB)
- **Name**: `shangwellness-prod-alb`
- **DNS**: `shangwellness-prod-alb-1303215459.ap-south-1.elb.amazonaws.com`
- **Health Check**: `/healthcheck`
- **Target Groups**: 2 (for Blue/Green deployment)

### 4. 🔄 CI/CD Pipeline

#### CodePipeline
- **Name**: `shangwellness-prod-pipeline`
- **Stages**: 3 (Source, Build, Deploy)
- **Source**: S3 placeholder (configurable for Git)
- **Build**: CodeBuild with custom buildspec
- **Deploy**: CodeDeploy with Blue/Green strategy

#### CodeBuild
- **Project**: `shangwellness-prod`
- **Image**: Amazon Linux 2
- **Runtime**: Docker 20
- **Buildspec**: Custom `buildspec.yml`

#### CodeDeploy
- **Application**: `shangwellness-prod-codedeploy`
- **Deployment Group**: `shangwellness-prod-deployment-group`
- **Strategy**: Blue/Green with Canary
- **Configuration**: `CodeDeployDefault.ECSCanary10Percent5Minutes`

### 5. 📦 Container Registry - ECR

#### ECR Repository
- **Name**: `shangwellness-prod`
- **URI**: `669097061043.dkr.ecr.ap-south-1.amazonaws.com/shangwellness-prod`
- **Image Scanning**: Enabled
- **Lifecycle Policy**: Configured

### 6. 🔐 Security & IAM

#### Security Groups
- **ALB SG**: Allows HTTP/HTTPS from internet
- **ECS SG**: Allows traffic from ALB
- **RDS SG**: Allows MySQL from ECS

#### IAM Roles
- **ECS Task Role**: Application permissions
- **ECS Execution Role**: ECR and CloudWatch access
- **CodeBuild Role**: S3, ECR, ECS permissions
- **CodeDeploy Role**: ECS deployment permissions

### 7. 📊 Monitoring & Logging

#### CloudWatch
- **Log Groups**:
  - `/ecs/prod/web-app` (Application logs)
  - `/aws/codebuild/shangwellness-prod` (Build logs)
- **Metrics**: CPU, Memory, Request count, Error rate

#### Auto Scaling
- **CPU Policy**: Scale when CPU > 70%
- **Memory Policy**: Scale when Memory > 80%
- **Min/Max**: 1-10 tasks

## 🔄 Deployment Strategy

### Blue/Green Deployment
1. **Blue Environment**: Current production
2. **Green Environment**: New version deployment
3. **Traffic Routing**: Load balancer switches traffic
4. **Validation**: Health checks and monitoring
5. **Rollback**: Automatic on failure

### Canary Deployment
- **Phase 1**: 10% traffic to new version (5 minutes)
- **Phase 2**: 100% traffic to new version
- **Monitoring**: Health checks and metrics
- **Rollback**: Automatic if health checks fail

## 🔒 Security Features

### Network Security
- **VPC Isolation**: Private subnets for compute
- **Security Groups**: Least privilege access
- **NAT Gateway**: Outbound internet access
- **Database Isolation**: Private subnets

### Data Security
- **Encryption at Rest**: All data encrypted
- **Encryption in Transit**: TLS/SSL for all connections
- **Secrets Management**: Database credentials in Secrets Manager
- **IAM Roles**: Least privilege access

### Application Security
- **Image Scanning**: ECR vulnerability scanning
- **Health Checks**: Application health monitoring
- **Auto Scaling**: Protection against DDoS
- **Logging**: Comprehensive audit trails

## 📈 Scalability Features

### Horizontal Scaling
- **ECS Auto Scaling**: Based on CPU/Memory
- **Load Balancer**: Distributes traffic
- **Database**: Aurora Serverless v2 auto-scaling

### Vertical Scaling
- **Task Definition**: CPU/Memory configuration
- **Database**: Instance scaling
- **Load Balancer**: Capacity scaling

## 🚨 High Availability

### Multi-AZ Deployment
- **ECS**: Tasks across 2 AZs
- **RDS**: Multi-AZ cluster
- **ALB**: Cross-zone load balancing
- **VPC**: Resources in multiple AZs

### Fault Tolerance
- **Auto Scaling**: Automatic recovery
- **Health Checks**: Continuous monitoring
- **Rollback**: Automatic on failure
- **Backups**: Automated database backups

## 💰 Cost Optimization

### Serverless Components
- **ECS Fargate**: Pay per task
- **Aurora Serverless**: Pay per ACU
- **CodeBuild**: Pay per build minute

### Resource Optimization
- **Auto Scaling**: Scale down during low usage
- **Lifecycle Policies**: ECR image cleanup
- **Monitoring**: Cost alerts and optimization

## 📋 Configuration Files

### Key Configuration Files
- `main.tf`: Main Terraform configuration
- `buildspec.yml`: CodeBuild configuration
- `shangwellness_appspec.yml`: CodeDeploy configuration
- `taskdef_shangwellness.json`: ECS task definition
- `variables.tf`: Terraform variables
- `outputs.tf`: Terraform outputs

### Environment Variables
```bash
DB_NAME=shangwellness_prod
APP_ENV=production
DB_USERNAME=admin
DB_HOST=shangwellness-prod-aurora.cluster-cj8iwom2850v.ap-south-1.rds.amazonaws.com
DB_PASSWORD=<from-secrets-manager>
```

## 🔧 Maintenance Procedures

### Regular Maintenance
- **Security Updates**: Monthly patching
- **Backup Verification**: Weekly backup tests
- **Performance Monitoring**: Continuous monitoring
- **Cost Review**: Monthly cost analysis

### Emergency Procedures
- **Service Outage**: Immediate response procedures
- **Data Recovery**: Backup restoration procedures
- **Security Incident**: Incident response procedures

## 📞 Support Information

### Contact Information
- **DevOps Team**: devops-team@company.com
- **AWS Support**: Available through AWS Console
- **Emergency Contact**: +1-XXX-XXX-XXXX

### Documentation
- **Deployment Guide**: `DEPLOYMENT.md`
- **Troubleshooting Guide**: `TROUBLESHOOTING.md`
- **Runbooks**: Available in internal wiki

---

**Last Updated**: August 8, 2025  
**Version**: 1.0  
**Maintained By**: DevOps Team 