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

variable "api_container_image" {
  description = "API container image URI"
  type        = string
  default     = "your-account-id.dkr.ecr.ap-northeast-2.amazonaws.com/ecg-api:latest"
}

variable "model_instance_type" {
  description = "EC2 instance type for model server"
  type        = string
  default     = "g4dn.xlarge"
}

variable "github_repo_url" {
  description = "GitHub repository URL for the ECG audio analyzer"
  type        = string
  default     = "https://github.com/teamKimtaerin/ecg-audio-analyzer.git"
}

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

variable "domain_name" {
  description = "Domain name for the application (optional)"
  type        = string
  default     = null
}

variable "create_certificate" {
  description = "Whether to create ACM certificate"
  type        = bool
  default     = false
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