# 🔒 Security Guide - Shangwellness Production Infrastructure

## 🛡️ Security Overview

This guide outlines the security measures, best practices, and compliance requirements for the Shangwellness production infrastructure.

## 🔐 Security Architecture

### Defense in Depth
```
┌─────────────────────────────────────────────────────────────┐
│                    Internet Layer                           │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │   WAF       │  │   CloudFront│  │   Route 53  │        │
│  │ (Web App    │  │   (CDN)     │  │   (DNS)     │        │
│  │  Firewall)  │  │             │  │             │        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   Network Layer                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │   VPC       │  │   Security  │  │   NAT       │        │
│  │ (Isolation) │  │   Groups    │  │   Gateway   │        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                  Application Layer                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │   ECS       │  │   IAM       │  │   Secrets   │        │
│  │ (Containers)│  │   (Access)  │  │   Manager   │        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   Data Layer                                │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │   RDS       │  │   S3        │  │   ECR       │        │
│  │ (Database)  │  │ (Storage)   │  │ (Registry)  │        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
└─────────────────────────────────────────────────────────────┘
```

## 🔒 Security Controls

### 1. Network Security

#### VPC Configuration
- **CIDR Block**: `10.0.0.0/16`
- **Subnet Isolation**: Public, Private, and Database subnets
- **NAT Gateway**: For outbound internet access from private subnets
- **Internet Gateway**: For public subnets only

#### Security Groups
```bash
# ALB Security Group (sg-059ec2129f7137c85)
- Inbound: HTTP (80), HTTPS (443) from 0.0.0.0/0
- Outbound: All traffic to 0.0.0.0/0

# ECS Security Group (sg-040c1c97008d7cf1a)
- Inbound: HTTP (80) from ALB security group
- Outbound: All traffic to 0.0.0.0/0

# RDS Security Group (sg-061c1a05d15ae83d7)
- Inbound: MySQL (3306) from ECS security group
- Outbound: None
```

### 2. Identity and Access Management (IAM)

#### IAM Roles
- **ECS Task Role**: Application-specific permissions
- **ECS Execution Role**: ECR and CloudWatch access
- **CodeBuild Role**: S3, ECR, ECS permissions
- **CodeDeploy Role**: ECS deployment permissions

#### IAM Policies
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage"
      ],
      "Resource": "*"
    }
  ]
}
```

### 3. Data Security

#### Encryption at Rest
- **RDS**: AES-256 encryption enabled
- **S3**: Server-side encryption (SSE-S3)
- **ECR**: Container images encrypted
- **EBS**: Volume encryption enabled

#### Encryption in Transit
- **HTTPS**: TLS 1.2+ for all web traffic
- **Database**: SSL/TLS for database connections
- **API**: HTTPS for all API calls
- **Internal**: VPC encryption for internal traffic

#### Secrets Management
```bash
# Database credentials in Secrets Manager
aws secretsmanager get-secret-value \
  --secret-id shangwellness-prod-aurora-master-password \
  --region ap-south-1
```

### 4. Application Security

#### Container Security
- **Image Scanning**: ECR vulnerability scanning enabled
- **Base Images**: Official, trusted base images
- **Multi-stage Builds**: Minimize attack surface
- **Non-root User**: Containers run as non-root

#### Health Checks
```yaml
# Application health check
healthCheck:
  path: /healthcheck
  port: 80
  protocol: HTTP
  interval: 30s
  timeout: 5s
  healthyThreshold: 2
  unhealthyThreshold: 3
```

### 5. Monitoring and Logging

#### CloudWatch Logs
- **Application Logs**: `/ecs/prod/web-app`
- **Build Logs**: `/aws/codebuild/shangwellness-prod`
- **Access Logs**: ALB access logs
- **Database Logs**: RDS slow query logs

#### CloudTrail
- **API Logging**: All AWS API calls logged
- **S3 Bucket**: CloudTrail logs stored in S3
- **CloudWatch Integration**: Real-time monitoring

## 🚨 Security Monitoring

### CloudWatch Alarms
```bash
# Security-related alarms
- Unauthorized API calls
- Failed authentication attempts
- Unusual data access patterns
- Resource modification alerts
```

### Key Metrics
- **Authentication Failures**: Monitor login attempts
- **API Errors**: Track 4xx/5xx responses
- **Database Connections**: Monitor connection patterns
- **Network Traffic**: Track unusual traffic patterns

## 🔍 Security Best Practices

### 1. Access Control
- **Principle of Least Privilege**: Minimum required permissions
- **Role-based Access**: Use IAM roles instead of users
- **Temporary Credentials**: Use STS for temporary access
- **MFA**: Enable multi-factor authentication

### 2. Network Security
- **Security Groups**: Restrict traffic to minimum required
- **NACLs**: Additional network layer protection
- **VPC Flow Logs**: Monitor network traffic
- **Private Subnets**: Keep resources in private subnets

### 3. Data Protection
- **Backup Encryption**: Encrypt all backups
- **Data Classification**: Classify data by sensitivity
- **Retention Policies**: Define data retention periods
- **Secure Disposal**: Properly dispose of sensitive data

### 4. Application Security
- **Input Validation**: Validate all user inputs
- **Output Encoding**: Encode output to prevent XSS
- **SQL Injection**: Use parameterized queries
- **Session Management**: Secure session handling

## 🔧 Security Configuration

### Security Headers
```nginx
# Security headers for web application
add_header X-Frame-Options "SAMEORIGIN";
add_header X-Content-Type-Options "nosniff";
add_header X-XSS-Protection "1; mode=block";
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains";
add_header Content-Security-Policy "default-src 'self'";
```

### SSL/TLS Configuration
```nginx
# SSL configuration
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512;
ssl_prefer_server_ciphers off;
ssl_session_cache shared:SSL:10m;
ssl_session_timeout 10m;
```

### Database Security
```sql
-- Database security settings
SET GLOBAL max_connections = 100;
SET GLOBAL wait_timeout = 600;
SET GLOBAL interactive_timeout = 600;

-- User permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON shangwellness_prod.* TO 'app_user'@'%';
REVOKE ALL PRIVILEGES ON *.* FROM 'app_user'@'%';
```

## 🚨 Incident Response

### Security Incident Types
1. **Data Breach**: Unauthorized access to sensitive data
2. **DDoS Attack**: Distributed denial of service
3. **Malware**: Malicious software detection
4. **Account Compromise**: Unauthorized account access

### Response Procedures
1. **Detection**: Automated monitoring and alerting
2. **Assessment**: Evaluate impact and scope
3. **Containment**: Isolate affected systems
4. **Eradication**: Remove threat and vulnerabilities
5. **Recovery**: Restore normal operations
6. **Lessons Learned**: Document and improve

### Emergency Contacts
- **Security Team**: security@company.com
- **CISO**: ciso@company.com
- **Legal Team**: legal@company.com
- **External Security**: +1-XXX-XXX-XXXX

## 📋 Compliance Requirements

### GDPR Compliance
- **Data Minimization**: Collect only necessary data
- **Consent Management**: Clear consent mechanisms
- **Right to Erasure**: Data deletion capabilities
- **Data Portability**: Export capabilities

### SOC 2 Compliance
- **Security**: Protect against unauthorized access
- **Availability**: Ensure system availability
- **Processing Integrity**: Accurate and complete processing
- **Confidentiality**: Protect confidential information
- **Privacy**: Protect personal information

### PCI DSS Compliance
- **Network Security**: Secure network infrastructure
- **Access Control**: Restrict access to cardholder data
- **Vulnerability Management**: Regular security assessments
- **Monitoring**: Monitor access to cardholder data

## 🔍 Security Auditing

### Regular Audits
- **Monthly**: Security group review
- **Quarterly**: IAM permission audit
- **Semi-annually**: Penetration testing
- **Annually**: Security assessment

### Audit Tools
- **AWS Config**: Configuration compliance
- **Security Hub**: Security findings
- **GuardDuty**: Threat detection
- **Inspector**: Vulnerability assessment

## 📚 Security Resources

### Documentation
- **AWS Security Best Practices**: https://aws.amazon.com/security/security-learning/
- **OWASP Top 10**: https://owasp.org/www-project-top-ten/
- **NIST Cybersecurity Framework**: https://www.nist.gov/cyberframework

### Tools
- **Security Scanning**: AWS Inspector, ECR scanning
- **Monitoring**: CloudWatch, CloudTrail
- **Threat Detection**: GuardDuty, Security Hub
- **Compliance**: AWS Config, Security Hub

---

**Last Updated**: August 8, 2025  
**Version**: 1.0  
**Maintained By**: Security Team 