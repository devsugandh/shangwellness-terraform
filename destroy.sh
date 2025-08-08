#!/bin/bash

# AWS Fargate Infrastructure Destroy Script
# This script provides a safe way to destroy the infrastructure

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the right directory
if [ ! -f "main/main.tf" ]; then
    print_error "Please run this script from the root directory of the project"
    exit 1
fi

# Check if terraform is installed
if ! command -v terraform &> /dev/null; then
    print_error "Terraform is not installed. Please install Terraform first."
    exit 1
fi

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    print_error "AWS CLI is not installed. Please install AWS CLI first."
    exit 1
fi

# Check AWS credentials
if ! aws sts get-caller-identity &> /dev/null; then
    print_error "AWS credentials not configured. Please run 'aws configure' first."
    exit 1
fi

print_status "Starting infrastructure destruction..."

# Change to main directory
cd main

# Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
    print_error "terraform.tfvars file not found. Please create it with your configuration."
    exit 1
fi

# Initialize Terraform
print_status "Initializing Terraform..."
if ! terraform init; then
    print_error "Terraform initialization failed"
    exit 1
fi

# Plan the destruction
print_status "Planning destruction..."
if ! terraform plan -destroy -out=destroy-plan; then
    print_error "Terraform plan failed"
    exit 1
fi

# Show warning about what will be destroyed
echo
print_warning "This will destroy ALL infrastructure resources including:"
print_warning "- VPC and all subnets"
print_warning "- ECS cluster and services"
print_warning "- Aurora database cluster"
print_warning "- Application Load Balancer"
print_warning "- ECR repositories"
print_warning "- All security groups and IAM roles"
echo

# Ask for confirmation multiple times
read -p "Are you absolutely sure you want to destroy the infrastructure? (yes/NO): " -r
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    print_warning "Destruction cancelled"
    rm -f destroy-plan
    exit 0
fi

echo
read -p "Type 'DESTROY' to confirm: " -r
if [[ ! $REPLY =~ ^DESTROY$ ]]; then
    print_warning "Destruction cancelled"
    rm -f destroy-plan
    exit 0
fi

echo
print_warning "Proceeding with infrastructure destruction..."

# Apply the destruction
if terraform apply destroy-plan; then
    print_success "Infrastructure destroyed successfully!"
    
    # Clean up plan file
    rm -f destroy-plan
    
    print_success "All resources have been removed."
else
    print_error "Destruction failed"
    exit 1
fi 