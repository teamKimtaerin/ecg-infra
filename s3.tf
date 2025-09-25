# S3 bucket for video storage
resource "aws_s3_bucket" "video_storage" {
  bucket = "${var.project_name}-${var.environment}-video-storage-${random_string.bucket_suffix.result}"

  tags = {
    Name        = "${var.project_name}-${var.environment}-video-storage"
    Environment = var.environment
  }
}

# Random suffix for bucket name uniqueness
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# S3 bucket versioning
resource "aws_s3_bucket_versioning" "video_storage_versioning" {
  bucket = aws_s3_bucket.video_storage.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 bucket server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "video_storage_encryption" {
  bucket = aws_s3_bucket.video_storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 bucket public access block
resource "aws_s3_bucket_public_access_block" "video_storage_pab" {
  bucket = aws_s3_bucket.video_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 bucket CORS configuration
resource "aws_s3_bucket_cors_configuration" "video_storage_cors" {
  bucket = aws_s3_bucket.video_storage.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "POST", "PUT", "DELETE"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

# S3 bucket for CloudFront logs
resource "aws_s3_bucket" "cloudfront_logs" {
  bucket = "${var.project_name}-${var.environment}-cloudfront-logs-${random_string.bucket_suffix.result}"

  tags = {
    Name        = "${var.project_name}-${var.environment}-cloudfront-logs"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_public_access_block" "cloudfront_logs_pab" {
  bucket = aws_s3_bucket.cloudfront_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 bucket ACL configuration for CloudFront logs
resource "aws_s3_bucket_acl" "cloudfront_logs_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.cloudfront_logs_ownership]
  
  bucket = aws_s3_bucket.cloudfront_logs.id
  acl    = "private"
}

resource "aws_s3_bucket_ownership_controls" "cloudfront_logs_ownership" {
  bucket = aws_s3_bucket.cloudfront_logs.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# S3 bucket for frontend static files
resource "aws_s3_bucket" "frontend" {
  bucket = "${var.project_name}-${var.environment}-frontend-${random_string.bucket_suffix.result}"

  tags = {
    Name        = "${var.project_name}-${var.environment}-frontend"
    Environment = var.environment
  }
}

# Frontend bucket website configuration for SPA routing
resource "aws_s3_bucket_website_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

# Frontend bucket public access block
resource "aws_s3_bucket_public_access_block" "frontend_pab" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 bucket for Plugin Server
resource "aws_s3_bucket" "plugin_server" {
  bucket = var.plugin_server_bucket_name != null ? var.plugin_server_bucket_name : (
    var.use_account_specific_bucket_names ?
    "${var.project_name}-${var.environment}-plugin-server-${data.aws_caller_identity.current.account_id}" :
    "${var.project_name}-${var.environment}-plugin-server-${random_string.bucket_suffix.result}"
  )

  tags = {
    name        = "ecg-project-plugin-server-s3"
    Name        = "${var.project_name}-${var.environment}-plugin-server"
    Environment = var.environment
  }

  lifecycle {
    prevent_destroy = true
  }
}

# Plugin Server bucket server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "plugin_server_encryption" {
  bucket = aws_s3_bucket.plugin_server.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# Plugin Server bucket public access block (현재는 퍼블릭 허용 상태 유지)
resource "aws_s3_bucket_public_access_block" "plugin_server_pab" {
  bucket = aws_s3_bucket.plugin_server.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Plugin Server bucket CORS configuration
resource "aws_s3_bucket_cors_configuration" "plugin_server_cors" {
  bucket = aws_s3_bucket.plugin_server.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "POST", "PUT", "DELETE", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag", "x-amz-meta-custom-header"]
    max_age_seconds = 3000
  }
}