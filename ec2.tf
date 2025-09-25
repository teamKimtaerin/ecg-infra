# Data source for latest Deep Learning AMI
data "aws_ami" "deep_learning" {
  count       = var.gpu_instance_enabled ? 1 : 0
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Deep Learning OSS Nvidia Driver AMI GPU PyTorch*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# GPU EC2 Instance for Audio Production
resource "aws_instance" "audio_production" {
  count                       = var.gpu_instance_enabled ? 1 : 0
  ami                         = data.aws_ami.deep_learning[0].id
  instance_type               = var.gpu_instance_type
  key_name                    = var.gpu_instance_key_name
  subnet_id                   = aws_subnet.public[0].id
  vpc_security_group_ids      = [aws_security_group.gpu_instance[0].id]
  iam_instance_profile        = aws_iam_instance_profile.audio_production[0].name
  associate_public_ip_address = true

  root_block_device {
    volume_type = "gp3"
    volume_size = var.gpu_instance_volume_size
    encrypted   = false
  }

  user_data = base64encode(templatefile("${path.module}/user_data/audio_production_init.sh", {
    region        = var.aws_region
    project_name  = var.project_name
    environment   = var.environment
  }))

  tags = {
    Name        = "${var.project_name}-${var.environment}-audio-production"
    Environment = var.environment
    Purpose     = "Audio Analysis and Production"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Elastic IP for Audio Production Instance
resource "aws_eip" "audio_production" {
  count    = var.gpu_instance_enabled ? 1 : 0
  instance = aws_instance.audio_production[0].id
  domain   = "vpc"

  tags = {
    Name        = "${var.project_name}-${var.environment}-audio-production-eip"
    Environment = var.environment
  }
}






