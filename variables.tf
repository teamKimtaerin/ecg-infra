variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "ecg-video-pipeline"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

# AWS Account Configuration
variable "aws_account_id" {
  description = "AWS Account ID for ECR and other account-specific resources"
  type        = string
  default     = null # Must be set in tfvars file
}

variable "api_container_image" {
  description = "API container image URI (will be constructed dynamically if not provided)"
  type        = string
  default     = null # Will use ECR repository from current account if not provided
}

# GPU instance variables DELETED (not used)


variable "api_cpu" {
  description = "CPU units for API service"
  type        = number
  default     = 512
}

variable "api_memory" {
  description = "Memory for API service"
  type        = number
  default     = 1024
}








# CloudFront Configuration
variable "cloudfront_domain_aliases" {
  description = "Custom domain aliases for CloudFront distribution"
  type        = list(string)
  default     = [] # Empty list means no custom domains
}

variable "cloudfront_certificate_arn" {
  description = "ACM Certificate ARN for CloudFront (must be in us-east-1)"
  type        = string
  default     = null # Will use default CloudFront certificate if not provided
}

# Database variables
variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "ecgdb"
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "postgres"
}

# Redis variables - DELETED (ElastiCache removed for cost optimization)

# GPU Instance variables (Audio Production)
variable "gpu_instance_enabled" {
  description = "Whether to create GPU instance for audio production"
  type        = bool
  default     = false
}

variable "gpu_instance_type" {
  description = "GPU instance type for audio production"
  type        = string
  default     = "g4dn.2xlarge"
}

variable "gpu_instance_volume_size" {
  description = "EBS volume size for GPU instance (GB)"
  type        = number
  default     = 100
}

variable "gpu_instance_key_name" {
  description = "EC2 Key Pair name for GPU instance"
  type        = string
  default     = null # Must be set if gpu_instance_enabled is true
}

# S3 Bucket Names (Account-specific)
variable "plugin_server_bucket_name" {
  description = "Name for plugin server S3 bucket (must be globally unique)"
  type        = string
  default     = null # Will use generated name if not provided
}

variable "use_account_specific_bucket_names" {
  description = "Whether to use account ID in bucket names for uniqueness"
  type        = bool
  default     = true
}