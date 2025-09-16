# Key Pair for EC2 instances
resource "aws_key_pair" "model_server" {
  key_name   = "${var.project_name}-${var.environment}-model-server-key"
  public_key = file("~/.ssh/id_rsa.pub") # Make sure this file exists

  tags = {
    Name        = "${var.project_name}-${var.environment}-model-server-key"
    Environment = var.environment
  }
}

# Get latest Ubuntu 22.04 LTS AMI
data "aws_ami" "ubuntu_gpu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Launch Template for Model Server (Ubuntu + Docker)
resource "aws_launch_template" "model_server" {
  name_prefix   = "${var.project_name}-${var.environment}-model-server-"
  image_id      = data.aws_ami.ubuntu_gpu.id
  instance_type = var.model_instance_type
  key_name      = aws_key_pair.model_server.key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.model_server_profile.name
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 50
      volume_type = "gp3"
      encrypted   = false
    }
  }

  user_data = base64encode(templatefile("${path.module}/user_data/model_server_docker.sh", {
    s3_bucket_name = aws_s3_bucket.video_storage.id
    aws_region     = var.aws_region
    repo_url       = var.github_repo_url
  }))

  tags = {
    Name        = "${var.project_name}-${var.environment}-model-server-template"
    Environment = var.environment
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.project_name}-${var.environment}-model-server"
      Environment = var.environment
    }
  }
}

# Remove deep learning AMI - using Ubuntu for all instances

# Launch Template for Renderer Server (Ubuntu)
resource "aws_launch_template" "renderer_server" {
  name_prefix   = "${var.project_name}-${var.environment}-renderer-server-"
  image_id      = data.aws_ami.ubuntu_gpu.id
  instance_type = var.model_instance_type
  key_name      = aws_key_pair.model_server.key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.model_server_profile.name
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 100
      volume_type = "gp3"
      encrypted   = false
    }
  }

  user_data = base64encode(templatefile("${path.module}/user_data/model_server_init.sh", {
    s3_bucket_name = aws_s3_bucket.video_storage.id
    aws_region     = var.aws_region
  }))

  tags = {
    Name        = "${var.project_name}-${var.environment}-renderer-server-template"
    Environment = var.environment
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.project_name}-${var.environment}-renderer-server"
      Environment = var.environment
    }
  }
}

# EC2 Instance for Model Server
resource "aws_instance" "model_server" {
  launch_template {
    id      = aws_launch_template.model_server.id
    version = "$Latest"
  }

  subnet_id              = aws_subnet.private[0].id
  private_ip             = "10.0.10.42"
  vpc_security_group_ids = [aws_security_group.model_server.id]

  tags = {
    Name        = "${var.project_name}-${var.environment}-model-server"
    Environment = var.environment
  }
}

# EC2 Instance for Renderer Server
resource "aws_instance" "renderer_server" {
  launch_template {
    id      = aws_launch_template.renderer_server.id
    version = "$Latest"
  }

  subnet_id              = aws_subnet.private[0].id
  private_ip             = "10.0.10.43"
  vpc_security_group_ids = [aws_security_group.model_server.id]

  tags = {
    Name        = "${var.project_name}-${var.environment}-renderer-server"
    Environment = var.environment
  }
}