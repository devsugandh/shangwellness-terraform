# ⚡ Quick Start Guide - Shangwellness Production Infrastructure

## 🎯 Overview

This guide helps you quickly understand and work with the Shangwellness production infrastructure. Perfect for new team members or quick reference.

## 🚀 Infrastructure at a Glance

| **Component** | **Name** | **Status** | **Access** |
|---------------|----------|------------|------------|
| **Application** | Shangwellness | ✅ Running | http://shangwellness-prod-alb-1303215459.ap-south-1.elb.amazonaws.com |
| **ECS Cluster** | shangwellness-prod-cluster | ✅ Active | AWS Console → ECS |
| **Database** | shangwellness-prod-aurora | ✅ Available | AWS Console → RDS |
| **Pipeline** | shangwellness-prod-pipeline | ✅ Ready | AWS Console → CodePipeline |

## 🔑 Quick Access Commands

### 1. Check Application Health
```bash
# Test application endpoint
curl -I http://shangwellness-prod-alb-1303215459.ap-south-1.elb.amazonaws.com/healthcheck

# Expected response: HTTP/1.1 200 OK
```

### 2. Check ECS Service Status
```bash
# Get service status
aws ecs describe-services \
  --cluster shangwellness-prod-cluster \
  --services shangwellness-prod-service \
  --region ap-south-1 \
  --query 'services[0].{Status:status,RunningCount:runningCount,DesiredCount:desiredCount}'
```

### 3. Check Database Status
```bash
# Get database status
aws rds describe-db-clusters \
  --db-cluster-identifier shangwellness-prod-aurora \
  --region ap-south-1 \
  --query 'DBClusters[0].{Status:Status,Endpoint:Endpoint}'
```

### 4. Check Pipeline Status
```bash
# Get pipeline state
aws codepipeline get-pipeline-state \
  --name shangwellness-prod-pipeline \
  --region ap-south-1
```

## 🛠️ Common Tasks

### Deploy New Version

#### Option 1: Manual Deployment
1. Go to AWS Console → CodePipeline
2. Select `shangwellness-prod-pipeline`
3. Click "Release change"
4. Monitor deployment progress

#### Option 2: Via AWS CLI
```bash
# Trigger manual release
aws codepipeline start-pipeline-execution \
  --name shangwellness-prod-pipeline \
  --region ap-south-1
```

### View Application Logs
```bash
# Get recent application logs
aws logs get-log-events \
  --log-group-name /ecs/prod/web-app \
  --log-stream-name <log-stream-name> \
  --region ap-south-1 \
  --start-time $(date -d '1 hour ago' +%s)000
```

### Scale Application
```bash
# Scale up for high load
aws ecs update-service \
  --cluster shangwellness-prod-cluster \
  --service shangwellness-prod-service \
  --desired-count 3 \
  --region ap-south-1

# Scale down for low load
aws ecs update-service \
  --cluster shangwellness-prod-cluster \
  --service shangwellness-prod-service \
  --desired-count 1 \
  --region ap-south-1
```

### Rollback Deployment
```bash
# Stop current deployment
aws deploy stop-deployment \
  --deployment-id <deployment-id> \
  --auto-rollback-enabled \
  --region ap-south-1
```

## 🔍 Monitoring Dashboard

### Key Metrics to Watch
- **ECS Service**: Running count, CPU/Memory usage
- **Application**: Response time, error rate
- **Database**: Connections, CPU usage
- **Load Balancer**: Target health, request count

### CloudWatch Dashboard
```
AWS Console → CloudWatch → Dashboards → Shangwellness-Prod
```

## 🚨 Emergency Procedures

### Application Down
1. **Check ECS Service**
   ```bash
   aws ecs describe-services \
     --cluster shangwellness-prod-cluster \
     --services shangwellness-prod-service \
     --region ap-south-1
   ```

2. **Check Application Logs**
   ```bash
   aws logs get-log-events \
     --log-group-name /ecs/prod/web-app \
     --log-stream-name <latest-stream> \
     --region ap-south-1
   ```

3. **Restart Service if Needed**
   ```bash
   aws ecs update-service \
     --cluster shangwellness-prod-cluster \
     --service shangwellness-prod-service \
     --force-new-deployment \
     --region ap-south-1
   ```

### Database Issues
1. **Check RDS Status**
   ```bash
   aws rds describe-db-clusters \
     --db-cluster-identifier shangwellness-prod-aurora \
     --region ap-south-1
   ```

2. **Check Security Groups**
   ```bash
   aws ec2 describe-security-groups \
     --group-ids sg-040c1c97008d7cf1a \
     --region ap-south-1
   ```

## 📋 Configuration Files

### Important Files
- `main/buildspec.yml` - Build configuration
- `main/shangwellness_appspec.yml` - Deployment configuration
- `main/taskdef_shangwellness.json` - Container configuration
- `main/main.tf` - Infrastructure configuration

### Environment Variables
```bash
# Key environment variables
DB_NAME=shangwellness_prod
APP_ENV=production
DB_USERNAME=admin
DB_HOST=shangwellness-prod-aurora.cluster-cj8iwom2850v.ap-south-1.rds.amazonaws.com
```

## 🔧 Development Workflow

### 1. Local Development
```bash
# Clone repository
git clone <repository-url>
cd riddhi-gsp-terraform

# Set AWS region
export AWS_DEFAULT_REGION=ap-south-1

# Check infrastructure status
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

## 📞 Support Resources

### Documentation
- **Infrastructure Overview**: `INFRASTRUCTURE_OVERVIEW.md`
- **Deployment Guide**: `DEPLOYMENT.md`
- **Troubleshooting Guide**: `TROUBLESHOOTING.md`

### Contacts
- **DevOps Team**: devops-team@company.com
- **Emergency**: +1-XXX-XXX-XXXX

### AWS Console Links
- **ECS**: https://ap-south-1.console.aws.amazon.com/ecs/
- **RDS**: https://ap-south-1.console.aws.amazon.com/rds/
- **CodePipeline**: https://ap-south-1.console.aws.amazon.com/codepipeline/
- **CloudWatch**: https://ap-south-1.console.aws.amazon.com/cloudwatch/

## 🎯 Quick Reference

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

---

**Last Updated**: August 8, 2025  
**Version**: 1.0  
**Maintained By**: DevOps Team 