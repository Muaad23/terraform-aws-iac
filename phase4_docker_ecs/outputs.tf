output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.phase4_demo.repository_url
}
