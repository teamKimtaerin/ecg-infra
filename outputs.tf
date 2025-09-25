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

output "s3_plugin_server_bucket" {
  description = "S3 bucket for plugin server"
  value       = aws_s3_bucket.plugin_server.id
}

output "s3_plugin_server_arn" {
  description = "S3 bucket ARN for plugin server"
  value       = aws_s3_bucket.plugin_server.arn
}

output "s3_plugin_server_domain_name" {
  description = "S3 bucket domain name for plugin server"
  value       = aws_s3_bucket.plugin_server.bucket_domain_name
}

# ECR Outputs
output "ecr_api_repository_url" {
  description = "ECR repository URL for API"
  value       = aws_ecr_repository.api.repository_url
}

output "ecr_renderer_repository_url" {
  description = "ECR repository URL for Renderer"
  value       = aws_ecr_repository.renderer.repository_url
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

# ECS Renderer service - DELETED (not used)

# Load Balancer Outputs
output "alb_dns_name" {
  description = "Application Load Balancer DNS name"
  value       = aws_lb.main.dns_name
}

output "alb_hosted_zone_id" {
  description = "Application Load Balancer hosted zone ID"
  value       = aws_lb.main.zone_id
}

# EC2 instances outputs - DELETED (instances not used)


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

# Model server security group - DELETED (not used)

# IAM Roles
output "ecs_task_role_arn" {
  description = "ECS task role ARN"
  value       = aws_iam_role.ecs_task_role.arn
}

# Model server role - DELETED (not used)

# Certificate output removed - certificates managed via GUI

# API URLs
output "api_url_http" {
  description = "HTTP API URL"
  value       = "http://${aws_lb.main.dns_name}"
}

output "api_url_https" {
  description = "HTTPS API URL"
  value       = "https://${aws_lb.main.dns_name}"
}

# Renderer URLs - DELETED (renderer service not used)

# RDS Outputs
output "rds_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = aws_db_instance.postgresql.endpoint
}

output "rds_port" {
  description = "RDS PostgreSQL port"
  value       = aws_db_instance.postgresql.port
}

output "database_url" {
  description = "Database connection URL"
  value       = "postgresql://${aws_db_instance.postgresql.username}:${random_password.db_password.result}@${aws_db_instance.postgresql.endpoint}:${aws_db_instance.postgresql.port}/${aws_db_instance.postgresql.db_name}"
  sensitive   = true
}

# Redis Outputs - DELETED (ElastiCache removed for cost optimization)

# GPU Instance Outputs (Audio Production)
output "gpu_instance_id" {
  description = "GPU instance ID"
  value       = var.gpu_instance_enabled ? aws_instance.audio_production[0].id : null
}

output "gpu_instance_public_ip" {
  description = "GPU instance public IP"
  value       = var.gpu_instance_enabled ? aws_eip.audio_production[0].public_ip : null
}

output "gpu_instance_private_ip" {
  description = "GPU instance private IP"
  value       = var.gpu_instance_enabled ? aws_instance.audio_production[0].private_ip : null
}

output "gpu_instance_dns" {
  description = "GPU instance public DNS"
  value       = var.gpu_instance_enabled ? aws_instance.audio_production[0].public_dns : null
}

output "gpu_instance_ssh_command" {
  description = "SSH command to connect to GPU instance"
  value       = var.gpu_instance_enabled && var.gpu_instance_key_name != null ? "ssh -i ~/.ssh/${var.gpu_instance_key_name}.pem ubuntu@${aws_eip.audio_production[0].public_ip}" : null
}

output "gpu_instance_security_group_id" {
  description = "GPU instance security group ID"
  value       = var.gpu_instance_enabled ? aws_security_group.gpu_instance[0].id : null
}