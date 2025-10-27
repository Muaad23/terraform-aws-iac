variable "vpc_id" {
  description = "VPC ID from Phase 1"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID from Phase 1"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID from Phase 1"
  type        = string
}

variable "target_group_arn" {
  description = "Target Group ARN from Phase 2 ALB"
  type        = string
}