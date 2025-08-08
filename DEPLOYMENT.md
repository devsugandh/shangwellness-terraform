# 🚀 Deployment Guide - Shangwellness Production Infrastructure

## 📋 Overview

This guide covers the deployment process for the Shangwellness production infrastructure running on AWS ECS with Blue/Green deployment strategy using CodeDeploy and canary deployments.

## 🏗️ Infrastructure Components

- **ECS Cluster**: `shangwellness-prod-cluster`
- **ECS Service**: `shangwellness-prod-service`
- **Container**: `shangwellness-app`
- **Image**: `669097061043.dkr.ecr.ap-south-1.amazonaws.com/shangwellness-prod:latest`
- **Database**: Aurora MySQL 8.0 (Serverless v2)
- **Load Balancer**: ALB with health checks
- **CI/CD**: CodePipeline with CodeBuild and CodeDeploy

## 🔄 Deployment Strategy

### Blue/Green with Canary
- **Strategy**: `CodeDeployDefault.ECSCanary10Percent5Minutes`
- **Canary Phase**: 10% traffic for 5 minutes
- **Production Phase**: 100% traffic after canary validation
- **Rollback**: Automatic rollback on deployment failure

## 📦 Pre-Deployment Checklist

### 1. Build Assets Preparation
```bash
# Ensure these files are in S3: s3://shangwellness-build-assets/prod-assets/
- .env                    # Environment variables
- Dockerfile             # Container definition
- shangwellness_appspec.yml  # CodeDeploy configuration
- taskdef_shangwellness.json # ECS task definition
- healthcheck.sh         # Health check script
- db.php                 # Database configuration
- docker/                # Docker-related files
```

### 2. ECR Image Verification
```bash
# Check if the image exists in ECR
aws ecr describe-images \
  --repository-name shangwellness-prod \
  --region ap-south-1 \
  --query 'imageDetails[*].[imageTags,imagePushedAt]' \
  --output table
```

### 3. Database Connectivity
```bash
# Verify database connectivity
aws rds describe-db-clusters \
  --db-cluster-identifier shangwellness-prod-aurora \
  --region ap-south-1 \
  --query 'DBClusters[0].{Status:Status,Endpoint:Endpoint}'
```

## 🚀 Deployment Process

### Method 1: Manual Deployment via CodePipeline

1. **Access CodePipeline Console**
   ```
   AWS Console → CodePipeline → shangwellness-prod-pipeline
   ```

2. **Trigger Manual Release**
   - Click "Release change" button
   - Monitor the deployment progress through stages

3. **Monitor Deployment**
   - **Source Stage**: Downloads source code
   - **Build Stage**: Builds Docker image and pushes to ECR
   - **Deploy Stage**: Executes Blue/Green deployment

### Method 2: Automated Deployment via Git

1. **Configure Source Stage**
   ```bash
   # Update CodePipeline source configuration
   aws codepipeline update-pipeline \
     --cli-input-json file://pipeline-config.json
   ```

2. **Push to Repository**
   ```bash
   git add .
   git commit -m "Deploy new version"
   git push origin main
   ```

3. **Monitor Automated Deployment**
   - Pipeline automatically triggers on code push
   - Monitor progress in CodePipeline console

### Method 3: Direct CodeDeploy Deployment

```bash
# Create deployment directly via CodeDeploy
aws deploy create-deployment \
  --application-name shangwellness-prod-codedeploy \
  --deployment-group-name shangwellness-prod-deployment-group \
  --s3-location bucket=shangwellness-prod-pipeline-artifacts-5a6cpjvx,key=appspec.yml \
  --region ap-south-1
```

## 📊 Deployment Monitoring

### 1. CodePipeline Status
```bash
# Check pipeline status
aws codepipeline get-pipeline-state \
  --name shangwellness-prod-pipeline \
  --region ap-south-1
```

### 2. CodeDeploy Deployment Status
```bash
# List recent deployments
aws deploy list-deployments \
  --application-name shangwellness-prod-codedeploy \
  --deployment-group-name shangwellness-prod-deployment-group \
  --region ap-south-1

# Get deployment details
aws deploy get-deployment \
  --deployment-id <deployment-id> \
  --region ap-south-1
```

### 3. ECS Service Status
```bash
# Check ECS service status
aws ecs describe-services \
  --cluster shangwellness-prod-cluster \
  --services shangwellness-prod-service \
  --region ap-south-1 \
  --query 'services[0].{Status:status,RunningCount:runningCount,DesiredCount:desiredCount}'
```

### 4. Application Health Check
```bash
# Test application health
curl -I http://shangwellness-prod-alb-1303215459.ap-south-1.elb.amazonaws.com/healthcheck
```

## 🔍 Deployment Validation

### 1. Health Check Verification
- ✅ Application responds to `/healthcheck` endpoint
- ✅ Database connectivity is established
- ✅ All environment variables are loaded correctly

### 2. Load Balancer Validation
- ✅ Target groups are healthy
- ✅ Traffic is being routed correctly
- ✅ SSL/TLS termination (if configured)

### 3. Performance Validation
- ✅ Response times are within acceptable limits
- ✅ Memory and CPU usage are normal
- ✅ No errors in application logs

## 🚨 Rollback Procedures

### Automatic Rollback
- CodeDeploy automatically rolls back on deployment failure
- Previous version remains active during rollback
- No manual intervention required

### Manual Rollback
```bash
# Stop current deployment
aws deploy stop-deployment \
  --deployment-id <deployment-id> \
  --auto-rollback-enabled \
  --region ap-south-1

# Or rollback to previous version
aws deploy create-deployment \
  --application-name shangwellness-prod-codedeploy \
  --deployment-group-name shangwellness-prod-deployment-group \
  --revision revisionType=S3,s3Location={bucket=artifacts,key=previous-version} \
  --region ap-south-1
```

## 📈 Post-Deployment Tasks

### 1. Monitoring Setup
- Verify CloudWatch alarms are active
- Check application logs for errors
- Monitor resource utilization

### 2. Performance Testing
- Run load tests to validate performance
- Check database query performance
- Verify auto-scaling behavior

### 3. Documentation Update
- Update deployment records
- Document any configuration changes
- Update runbooks if needed

## 🔧 Configuration Management

### Environment Variables
```bash
# Key environment variables in task definition
DB_NAME=shangwellness_prod
APP_ENV=production
DB_USERNAME=admin
DB_HOST=shangwellness-prod-aurora.cluster-cj8iwom2850v.ap-south-1.rds.amazonaws.com
DB_PASSWORD=<from-secrets-manager>
```

### Build Configuration
```yaml
# buildspec.yml key settings
runtime-versions:
  docker: 20
container_name: shangwellness-app
ecr_uri: 669097061043.dkr.ecr.ap-south-1.amazonaws.com/shangwellness-prod
```

## 📞 Support Contacts

- **DevOps Team**: devops-team@company.com
- **AWS Support**: Available through AWS Console
- **Emergency Contact**: +1-XXX-XXX-XXXX

---

**Last Updated**: August 8, 2025  
**Version**: 1.0  
**Maintained By**: DevOps Team 