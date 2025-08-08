# 🔧 Troubleshooting Guide - Shangwellness Production Infrastructure

## 🚨 Emergency Contacts

- **DevOps Team**: devops@hipster-inc.com | sugandh@hipster-inc.com | shashank@hipster-inc.com
- **AWS Support**: Available through AWS Console


## 📋 Quick Health Check Commands

```bash
# Check ECS service status
aws ecs describe-services \
  --cluster shangwellness-prod-cluster \
  --services shangwellness-prod-service \
  --region ap-south-1

# Check application health
curl -I http://dns.com/healthcheck

# Check database status
aws rds describe-db-clusters \
  --db-cluster-identifier shangwellness-prod-aurora \
  --region ap-south-1
```

## 🚨 Critical Issues

### 1. Application Not Responding

#### Symptoms
- HTTP 503 errors
- Health check failures
- No response from load balancer

#### Quick Fixes
```bash
# Check ECS service status
aws ecs describe-services \
  --cluster shangwellness-prod-cluster \
  --services shangwellness-prod-service \
  --region ap-south-1 \
  --query 'services[0].{Status:status,RunningCount:runningCount,DesiredCount:desiredCount}'

# Check ECS tasks
aws ecs list-tasks \
  --cluster shangwellness-prod-cluster \
  --service-name shangwellness-prod-service \
  --region ap-south-1

# Check task details
aws ecs describe-tasks \
  --cluster shangwellness-prod-cluster \
  --tasks <task-arn> \
  --region ap-south-1
```

#### Common Causes
- **Container crashes**: Check application logs
- **Resource exhaustion**: Check CPU/Memory usage
- **Database connectivity**: Verify RDS status
- **Image pull failures**: Check ECR repository

### 2. Database Connectivity Issues

#### Symptoms
- Application errors related to database
- Connection timeouts
- Authentication failures

#### Quick Fixes
```bash
# Check RDS cluster status
aws rds describe-db-clusters \
  --db-cluster-identifier shangwellness-prod-aurora \
  --region ap-south-1 \
  --query 'DBClusters[0].{Status:Status,Endpoint:Endpoint}'

# Check RDS instances
aws rds describe-db-cluster-instances \
  --db-cluster-identifier shangwellness-prod-aurora \
  --region ap-south-1

# Test database connectivity
mysql -h shangwellness-prod-aurora.cluster-cj8iwom2850v.ap-south-1.rds.amazonaws.com \
  -u admin -p -e "SELECT 1;"
```

#### Common Causes
- **RDS instance down**: Check instance status
- **Security group issues**: Verify ECS can reach RDS
- **Credential issues**: Check Secrets Manager
- **Network issues**: Verify VPC connectivity

### 3. Deployment Failures

#### Symptoms
- CodePipeline failures
- CodeDeploy deployment stuck
- Blue/Green deployment issues

#### Quick Fixes
```bash
# Check CodePipeline status
aws codepipeline get-pipeline-state \
  --name shangwellness-prod-pipeline \
  --region ap-south-1

# Check recent deployments
aws deploy list-deployments \
  --application-name shangwellness-prod-codedeploy \
  --deployment-group-name shangwellness-prod-deployment-group \
  --region ap-south-1

# Get deployment details
aws deploy get-deployment \
  --deployment-id <deployment-id> \
  --region ap-south-1
```

#### Common Causes
- **Build failures**: Check CodeBuild logs
- **Image push failures**: Check ECR permissions
- **AppSpec errors**: Verify YAML syntax
- **Task definition errors**: Check JSON format

## 🔍 Detailed Troubleshooting

### 1. ECS Service Issues

#### Service Not Starting
```bash
# Check service events
aws ecs describe-services \
  --cluster shangwellness-prod-cluster \
  --services shangwellness-prod-service \
  --region ap-south-1 \
  --query 'services[0].events[0:5]'

# Check task definition
aws ecs describe-task-definition \
  --task-definition shangwellness-prod-task \
  --region ap-south-1
```

#### Tasks Failing
```bash
# Get task logs
aws logs get-log-events \
  --log-group-name /ecs/prod/web-app \
  --log-stream-name <log-stream-name> \
  --region ap-south-1

# Check task stopped reason
aws ecs describe-tasks \
  --cluster shangwellness-prod-cluster \
  --tasks <task-arn> \
  --region ap-south-1 \
  --query 'tasks[0].stoppedReason'
```

#### Common ECS Issues
- **Insufficient CPU/Memory**: Increase task definition resources
- **Image pull errors**: Check ECR permissions and image existence
- **Port conflicts**: Verify container port mappings
- **Health check failures**: Check application health endpoint

### 2. Load Balancer Issues

#### Target Group Health
```bash
# Check target group health
aws elbv2 describe-target-health \
  --target-group-arn arn:aws:elasticloadbalancing:ap-south-1:669097061043:targetgroup/sw-prod-tg-443/3306735a155e4919 \
  --region ap-south-1

# Check ALB status
aws elbv2 describe-load-balancers \
  --load-balancer-arns arn:aws:elasticloadbalancing:ap-south-1:669097061043:loadbalancer/app/shangwellness-prod-alb/31b0991b5f7f1f7b \
  --region ap-south-1
```

#### Common ALB Issues
- **Targets unhealthy**: Check application health
- **Security group issues**: Verify ALB security group rules
- **Listener issues**: Check listener configuration
- **SSL certificate issues**: Verify ACM certificate status

### 3. CodeBuild Issues

#### Build Failures
```bash
# Get build logs
aws logs get-log-events \
  --log-group-name /aws/codebuild/shangwellness-prod \
  --log-stream-name <log-stream-name> \
  --region ap-south-1

# Check build project
aws codebuild batch-get-projects \
  --names shangwellness-prod \
  --region ap-south-1
```

#### Common Build Issues
- **Docker build failures**: Check Dockerfile syntax
- **S3 access issues**: Verify S3 bucket permissions
- **ECR push failures**: Check ECR repository permissions
- **Runtime issues**: Verify buildspec.yml syntax

### 4. CodeDeploy Issues

#### Deployment Failures
```bash
# Get deployment details
aws deploy get-deployment \
  --deployment-id <deployment-id> \
  --region ap-south-1

# Check deployment events
aws deploy get-deployment-target \
  --deployment-id <deployment-id> \
  --target-id <target-id> \
  --region ap-south-1
```

#### Common CodeDeploy Issues
- **AppSpec errors**: Check YAML syntax and structure
- **Task definition errors**: Verify JSON format
- **ECS service issues**: Check service configuration
- **Rollback failures**: Verify previous version availability

## 🔧 Common Fixes

### 1. Restart ECS Service
```bash
# Force new deployment
aws ecs update-service \
  --cluster shangwellness-prod-cluster \
  --service shangwellness-prod-service \
  --force-new-deployment \
  --region ap-south-1
```

### 2. Rollback Deployment
```bash
# Stop current deployment
aws deploy stop-deployment \
  --deployment-id <deployment-id> \
  --auto-rollback-enabled \
  --region ap-south-1
```

### 3. Scale Service
```bash
# Scale up for high load
aws ecs update-service \
  --cluster shangwellness-prod-cluster \
  --service shangwellness-prod-service \
  --desired-count 3 \
  --region ap-south-1
```

### 4. Check Logs
```bash
# Application logs
aws logs get-log-events \
  --log-group-name /ecs/prod/web-app \
  --log-stream-name <log-stream-name> \
  --region ap-south-1

# Build logs
aws logs get-log-events \
  --log-group-name /aws/codebuild/shangwellness-prod \
  --log-stream-name <log-stream-name> \
  --region ap-south-1
```

## 📊 Monitoring and Alerts

### CloudWatch Alarms
- **CPU Utilization**: > 80% for 5 minutes
- **Memory Utilization**: > 80% for 5 minutes
- **Target Group Health**: Unhealthy targets
- **Database CPU**: > 80% for 5 minutes

### Key Metrics to Monitor
- ECS service running count
- Application response time
- Database connections
- Error rates
- Deployment success rate

## 🚨 Emergency Procedures

### 1. Complete Service Outage
1. Check ECS service status
2. Verify database connectivity
3. Check load balancer health
4. Review recent deployments
5. Consider rollback if needed

### 2. Database Issues
1. Check RDS cluster status
2. Verify security group rules
3. Check connection limits
4. Review slow query logs
5. Consider scaling if needed

### 3. Deployment Issues
1. Stop current deployment
2. Check build logs
3. Verify artifacts
4. Rollback to previous version
5. Investigate root cause

## 📞 Escalation Matrix

| **Issue Type** | **First Response** | **Escalation** | **Emergency** |
|----------------|-------------------|----------------|---------------|
| Application Down | DevOps Team (30 min) | Senior DevOps (1 hour) | On-call Engineer (15 min) |
| Database Issues | DevOps Team (1 hour) | DBA Team (2 hours) | Senior DBA (30 min) |
| Deployment Failures | DevOps Team (2 hours) | Platform Team (4 hours) | Senior Platform (1 hour) |
| Security Issues | Security Team (1 hour) | CISO (2 hours) | Security Lead (30 min) |

## 📚 Additional Resources

- **AWS Documentation**: https://docs.aws.amazon.com/
- **ECS Troubleshooting**: https://docs.aws.amazon.com/ecs/latest/userguide/troubleshooting.html
- **CodeDeploy Troubleshooting**: https://docs.aws.amazon.com/codedeploy/latest/userguide/troubleshooting.html
- **RDS Troubleshooting**: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Troubleshooting.html

---

**Last Updated**: August 8, 2025  
**Version**: 1.0  
**Maintained By**: DevOps Team 