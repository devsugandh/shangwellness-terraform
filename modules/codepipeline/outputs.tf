# CodePipeline Module Outputs

output "pipeline_arn" {
  description = "ARN of the CodePipeline"
  value       = aws_codepipeline.main.arn
}

output "pipeline_name" {
  description = "Name of the CodePipeline"
  value       = aws_codepipeline.main.name
}

output "pipeline_id" {
  description = "ID of the CodePipeline"
  value       = aws_codepipeline.main.id
}

output "artifact_bucket_name" {
  description = "Name of the S3 bucket used for artifacts"
  value       = aws_s3_bucket.artifact_store.bucket
}

output "artifact_bucket_arn" {
  description = "ARN of the S3 bucket used for artifacts"
  value       = aws_s3_bucket.artifact_store.arn
}

output "codepipeline_role_arn" {
  description = "ARN of the CodePipeline IAM role"
  value       = aws_iam_role.codepipeline_role.arn
}

output "codepipeline_role_name" {
  description = "Name of the CodePipeline IAM role"
  value       = aws_iam_role.codepipeline_role.name
} 