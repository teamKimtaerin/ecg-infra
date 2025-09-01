# VPC Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = aws_subnet.private[*].id
}

# S3 Outputs
output "s3_video_storage_bucket" {
  description = "S3 bucket for video storage"
  value       = aws_s3_bucket.video_storage.id
}

output "s3_video_storage_arn" {
  description = "S3 bucket ARN for video storage"
  value       = aws_s3_bucket.video_storage.arn
}

output "s3_frontend_bucket" {
  description = "S3 bucket for frontend static files"
  value       = aws_s3_bucket.frontend.id
}

output "s3_frontend_arn" {
  description = "S3 bucket ARN for frontend static files"
  value       = aws_s3_bucket.frontend.arn
}

# ECR Outputs
output "ecr_api_repository_url" {
  description = "ECR repository URL for API"
  value       = aws_ecr_repository.api.repository_url
}

# ECS Outputs
output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.api.name
}

# Load Balancer Outputs
output "alb_dns_name" {
  description = "Application Load Balancer DNS name"
  value       = aws_lb.main.dns_name
}

output "alb_hosted_zone_id" {
  description = "Application Load Balancer hosted zone ID"
  value       = aws_lb.main.zone_id
}

# EC2 Outputs
output "model_server_instance_id" {
  description = "Model server EC2 instance ID"
  value       = aws_instance.model_server.id
}

output "model_server_private_ip" {
  description = "Model server private IP"
  value       = aws_instance.model_server.private_ip
}

# CloudFront Outputs
output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.main.id
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.main.domain_name
}

output "cloudfront_url" {
  description = "CloudFront distribution URL"
  value       = "https://${aws_cloudfront_distribution.main.domain_name}"
}

# Security Groups
output "alb_security_group_id" {
  description = "ALB security group ID"
  value       = aws_security_group.alb.id
}

output "ecs_security_group_id" {
  description = "ECS security group ID"
  value       = aws_security_group.ecs.id
}

output "model_server_security_group_id" {
  description = "Model server security group ID"
  value       = aws_security_group.model_server.id
}

# IAM Roles
output "ecs_task_role_arn" {
  description = "ECS task role ARN"
  value       = aws_iam_role.ecs_task_role.arn
}

output "model_server_role_arn" {
  description = "Model server role ARN"
  value       = aws_iam_role.model_server_role.arn
}