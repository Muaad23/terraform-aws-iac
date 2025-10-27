resource "aws_ecr_repository" "phase4_demo" {
  name                 = "phase4-demo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "phase4-demo"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}