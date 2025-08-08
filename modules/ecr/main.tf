module "ecr" {
  source                                = "terraform-aws-modules/ecr/aws"
  version                               = "2.4.0"
  create_repository                     = var.create_ecr_repository
  repository_type                       = "private"
  repository_name                       = var.ecr_repository_name
  repository_force_delete               = true
  repository_image_tag_mutability       = "MUTABLE"

  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep the last ${var.ecr_retention_count} images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = var.ecr_retention_count
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = {
    Terraform = "true"
    Environment = var.environment
    Project = var.name
  }
}