#!/bin/bash

# AWS Fargate Infrastructure Deployment Script
# This script provides a simple way to deploy the infrastructure

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

print_status "Starting deployment..."

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

# Validate Terraform configuration
print_status "Validating Terraform configuration..."
if ! terraform validate; then
    print_error "Terraform validation failed"
    exit 1
fi

# Plan the deployment
print_status "Planning deployment..."
if ! terraform plan -out=tfplan; then
    print_error "Terraform plan failed"
    exit 1
fi

# Ask for confirmation
echo
print_warning "Review the plan above carefully."
read -p "Do you want to apply these changes? (y/N): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_status "Applying changes..."
    if terraform apply tfplan; then
        print_success "Deployment completed successfully!"
        
        # Show outputs
        echo
        print_status "Infrastructure outputs:"
        terraform output
        
        # Clean up plan file
        rm -f tfplan
        
        print_success "Your infrastructure is now ready!"
    else
        print_error "Deployment failed"
        exit 1
    fi
else
    print_warning "Deployment cancelled"
    rm -f tfplan
    exit 0
fi 