output "ecr_repository_url" {
  description = "The URL of the repository"
  value       = module.ecr.repository_url
}

output "ecr_repository_arn" {
  description = "The ARN of the repository"
  value       = module.ecr.repository_arn
}

output "ecr_login_endpoint" {
  description = "The ECR login endpoint (registry URI without repo name)"
  value       = split("/", module.ecr.repository_url)[0]
}

output "repository_name" {
  description = "The name of the repository"
  value       = module.ecr.repository_name
}