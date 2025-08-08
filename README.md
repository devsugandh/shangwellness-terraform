# 🚀 Shangwellness Production Infrastructure

A production-ready AWS infrastructure for the Shangwellness application using ECS Fargate with Blue/Green deployment strategy, CodeDeploy, and canary deployments.

## 📋 Quick Overview

| **Component** | **Status** | **Details** |
|---------------|------------|-------------|
| **Application** | ✅ Running | ECS Fargate with Blue/Green deployment |
| **Database** | ✅ Available | Aurora MySQL 8.0 (Serverless v2) |
| **CI/CD** | ✅ Ready | CodePipeline with CodeBuild and CodeDeploy |
| **Monitoring** | ✅ Active | CloudWatch logs and metrics |
| **Security** | ✅ Secured | VPC isolation, IAM roles, encryption |

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Internet      │    │   Application   │    │   ECS Fargate   │
│   Users         │───▶│   Load Balancer │───▶│   (Containers)  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                                        │
                                                        ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   CodePipeline  │    │   CodeBuild     │    │   Aurora MySQL  │
│   (CI/CD)       │───▶│   (Build)       │───▶│   (Database)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🚀 Quick Start

### 1. Check Application Health
```bash
curl -I http://shangwellness-prod-alb-1303215459.ap-south-1.elb.amazonaws.com/healthcheck
```

### 2. Check Infrastructure Status
```bash
# ECS Service
aws ecs describe-services \
  --cluster shangwellness-prod-cluster \
  --services shangwellness-prod-service \
  --region ap-south-1

# Database
aws rds describe-db-clusters \
  --db-cluster-identifier shangwellness-prod-aurora \
  --region ap-south-1
```

### 3. Deploy New Version
```bash
# Manual deployment
aws codepipeline start-pipeline-execution \
  --name shangwellness-prod-pipeline \
  --region ap-south-1
```

## 📚 Documentation

### 📖 Core Documentation
- **[Quick Start Guide](QUICK_START.md)** - Get up and running quickly
- **[Infrastructure Overview](INFRASTRUCTURE_OVERVIEW.md)** - Detailed architecture and components
- **[Deployment Guide](DEPLOYMENT.md)** - Complete deployment procedures
- **[Troubleshooting Guide](TROUBLESHOOTING.md)** - Common issues and solutions
- **[Security Guide](SECURITY_GUIDE.md)** - Security measures and best practices

### 🔧 Configuration Files
- `main/main.tf` - Main Terraform configuration
- `main/buildspec.yml` - CodeBuild configuration
- `main/shangwellness_appspec.yml` - CodeDeploy configuration
- `main/taskdef_shangwellness.json` - ECS task definition
- `main/variables.tf` - Terraform variables
- `main/outputs.tf` - Terraform outputs

## 🏛️ Infrastructure Components

### 🚀 Compute Layer
- **ECS Cluster**: `shangwellness-prod-cluster`
- **ECS Service**: `shangwellness-prod-service`
- **Container**: `shangwellness-app`
- **Image**: `669097061043.dkr.ecr.ap-south-1.amazonaws.com/shangwellness-prod:latest`

### 🗄️ Database Layer
- **Engine**: Aurora MySQL 8.0
- **Cluster**: `shangwellness-prod-aurora`
- **Type**: Serverless v2
- **Backup**: Automated daily backups

### 🔄 CI/CD Pipeline
- **Pipeline**: `shangwellness-prod-pipeline`
- **Strategy**: Blue/Green with Canary
- **Build**: CodeBuild with custom buildspec
- **Deploy**: CodeDeploy with automatic rollback

### 🌐 Network Layer
- **VPC**: Multi-AZ deployment
- **Load Balancer**: ALB with health checks
- **Security Groups**: Proper network isolation
- **Region**: `ap-south-1` (Mumbai)

## 🔒 Security Features

- ✅ **VPC Isolation**: Private subnets for compute resources
- ✅ **IAM Roles**: Least privilege access control
- ✅ **Encryption**: At rest and in transit
- ✅ **Secrets Management**: Database credentials in Secrets Manager
- ✅ **Image Scanning**: ECR vulnerability scanning
- ✅ **Health Checks**: Application health monitoring

## 📊 Monitoring & Observability

- ✅ **CloudWatch Logs**: Application and build logs
- ✅ **CloudWatch Metrics**: CPU, Memory, Request count
- ✅ **Auto Scaling**: Based on CPU (70%) and Memory (80%)
- ✅ **Health Checks**: `/healthcheck` endpoint monitoring

## 🚨 Emergency Procedures

### Application Down
1. Check ECS service status
2. Review application logs
3. Verify database connectivity
4. Consider rollback if needed

### Quick Commands
```bash
# Check service status
aws ecs describe-services \
  --cluster shangwellness-prod-cluster \
  --services shangwellness-prod-service \
  --region ap-south-1

# Force new deployment
aws ecs update-service \
  --cluster shangwellness-prod-cluster \
  --service shangwellness-prod-service \
  --force-new-deployment \
  --region ap-south-1
```

## 🔧 Development Workflow

### 1. Local Development
```bash
# Clone repository
git clone <repository-url>
cd riddhi-gsp-terraform

# Set AWS region
export AWS_DEFAULT_REGION=ap-south-1

# Check infrastructure
terraform plan
```

### 2. Testing Changes
```bash
# Test Terraform changes
terraform plan

# Apply changes (if approved)
terraform apply
```

### 3. Deployment Process
1. Update application code
2. Build and test locally
3. Push to repository
4. Monitor deployment
5. Verify application health

## 📞 Support & Contacts

### Team Contacts
- **DevOps Team**: devops-team@company.com
- **Security Team**: security@company.com
- **Emergency Contact**: +1-XXX-XXX-XXXX

### AWS Console Links
- **ECS**: https://ap-south-1.console.aws.amazon.com/ecs/
- **RDS**: https://ap-south-1.console.aws.amazon.com/rds/
- **CodePipeline**: https://ap-south-1.console.aws.amazon.com/codepipeline/
- **CloudWatch**: https://ap-south-1.console.aws.amazon.com/cloudwatch/

## 🎯 Key Metrics

### Service Endpoints
- **Application**: http://shangwellness-prod-alb-1303215459.ap-south-1.elb.amazonaws.com
- **Health Check**: http://shangwellness-prod-alb-1303215459.ap-south-1.elb.amazonaws.com/healthcheck
- **Database**: shangwellness-prod-aurora.cluster-cj8iwom2850v.ap-south-1.rds.amazonaws.com

### Resource Names
- **ECS Cluster**: shangwellness-prod-cluster
- **ECS Service**: shangwellness-prod-service
- **RDS Cluster**: shangwellness-prod-aurora
- **Pipeline**: shangwellness-prod-pipeline
- **ECR Repository**: shangwellness-prod

### AWS Region
- **Primary Region**: ap-south-1 (Mumbai)

## 📋 Prerequisites

### Required Tools
- **AWS CLI**: Configured with appropriate permissions
- **Terraform**: Version 1.0 or higher
- **Docker**: For local container testing
- **Git**: For version control

### AWS Permissions
- ECS Full Access
- RDS Full Access
- CodePipeline Full Access
- CodeBuild Full Access
- CodeDeploy Full Access
- IAM Role Management
- VPC Management

## 🚀 Getting Started

1. **Read the Quick Start Guide**: [QUICK_START.md](QUICK_START.md)
2. **Understand the Architecture**: [INFRASTRUCTURE_OVERVIEW.md](INFRASTRUCTURE_OVERVIEW.md)
3. **Learn Deployment Procedures**: [DEPLOYMENT.md](DEPLOYMENT.md)
4. **Know Troubleshooting**: [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
5. **Review Security**: [SECURITY_GUIDE.md](SECURITY_GUIDE.md)

## 📈 Future Enhancements

- [ ] **SSL/TLS**: Add ACM certificate for HTTPS
- [ ] **Custom Domain**: Configure Route 53 for domain
- [ ] **CDN**: Add CloudFront for global distribution
- [ ] **WAF**: Implement Web Application Firewall
- [ ] **Backup Strategy**: Enhanced backup and recovery
- [ ] **Cost Optimization**: Implement cost monitoring and alerts

---

**Last Updated**: August 8, 2025  
**Version**: 1.0  
**Maintained By**: DevOps Team  
**Status**: Production Ready ✅
