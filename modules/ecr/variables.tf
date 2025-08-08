variable "create_ecr_repository" {
  description = "Determines whether resources will be created (affects all resources)"
  type        = bool
  default     = false
}
variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = ""
}
variable "ecr_repository_name" {
  description = "ECR Repo name"
  type        = string
  default     = ""
}
variable "environment" {
  type        = string
  default     = "uat"
}
variable "ecr_retention_count" {
  description = "The number of images to retain in the ECR repository"
  type        = number
  default     = 3
}