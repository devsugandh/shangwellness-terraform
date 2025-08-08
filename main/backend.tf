terraform {
  backend "s3" {
    bucket = "tfstateaug720251518"
    key    = "tfstateaug720251518-bucket"
    region = "ap-south-1"
  }
}

# Note: Backend configuration cannot use variables directly
# For different environments, you can use different backend config files:
# - backend-prod.tfbackend
# - backend-uat.tfbackend
# - backend-dev.tfbackend