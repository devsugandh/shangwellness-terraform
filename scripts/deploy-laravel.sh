#!/bin/bash

# Laravel Application Infrastructure Deployment Script
# This script deploys the complete Laravel infrastructure on AWS Fargate

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

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if Terraform is installed
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed. Please install Terraform first."
        exit 1
    fi
    
    # Check if AWS CLI is installed
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed. Please install AWS CLI first."
        exit 1
    fi
    
    # Check if AWS credentials are configured
    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "AWS credentials are not configured. Please run 'aws configure' first."
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

# Function to validate variables file
validate_variables() {
    print_status "Validating terraform.tfvars file..."
    
    if [ ! -f "main/laravel.tfvars" ]; then
        print_error "laravel.tfvars file not found in main directory"
        exit 1
    fi
    
    print_success "Variables file validation passed"
}

# Function to initialize Terraform
init_terraform() {
    print_status "Initializing Terraform..."
    
    cd main
    
    # Initialize Terraform
    terraform init
    
    print_success "Terraform initialized successfully"
}

# Function to plan Terraform deployment
plan_deployment() {
    print_status "Planning Terraform deployment..."
    
    # Run terraform plan
    terraform plan -var-file="laravel.tfvars" -out=tfplan
    
    print_success "Terraform plan completed"
}

# Function to apply Terraform deployment
apply_deployment() {
    print_status "Applying Terraform deployment..."
    
    # Apply the plan
    terraform apply tfplan
    
    print_success "Terraform deployment completed successfully"
}

# Function to show outputs
show_outputs() {
    print_status "Showing Terraform outputs..."
    
    terraform output
    
    print_success "Outputs displayed"
}

# Function to cleanup
cleanup() {
    print_status "Cleaning up temporary files..."
    
    if [ -f "tfplan" ]; then
        rm tfplan
    fi
    
    print_success "Cleanup completed"
}

# Function to destroy infrastructure
destroy_infrastructure() {
    print_warning "This will destroy all infrastructure including the Aurora database and its data!"
    read -p "Are you sure you want to continue? (yes/no): " confirm
    
    if [ "$confirm" = "yes" ]; then
        print_status "Destroying infrastructure..."
        terraform destroy -var-file="laravel.tfvars"
        print_success "Infrastructure destroyed successfully"
    else
        print_status "Destroy operation cancelled"
    fi
}

# Function to show help
show_help() {
    echo "Laravel Application Infrastructure Deployment Script"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  deploy     - Deploy the complete infrastructure"
    echo "  plan       - Plan the deployment without applying"
    echo "  destroy    - Destroy the infrastructure"
    echo "  outputs    - Show Terraform outputs"
    echo "  help       - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 deploy    # Deploy the infrastructure"
    echo "  $0 plan      # Plan the deployment"
    echo "  $0 destroy   # Destroy the infrastructure"
}

# Main script logic
main() {
    case "${1:-deploy}" in
        "deploy")
            check_prerequisites
            validate_variables
            init_terraform
            plan_deployment
            apply_deployment
            show_outputs
            cleanup
            print_success "Deployment completed successfully!"
            ;;
        "plan")
            check_prerequisites
            validate_variables
            init_terraform
            plan_deployment
            print_success "Plan completed successfully!"
            ;;
        "destroy")
            check_prerequisites
            validate_variables
            init_terraform
            destroy_infrastructure
            ;;
        "outputs")
            check_prerequisites
            validate_variables
            init_terraform
            show_outputs
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            print_error "Unknown command: $1"
            show_help
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@" 