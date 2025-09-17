#!/bin/bash

# ECS Agent configuration for Renderer Server
echo "ECS_CLUSTER=${cluster_name}" >> /etc/ecs/ecs.config
echo "ECS_ENABLE_GPU_SUPPORT=true" >> /etc/ecs/ecs.config
echo "ECS_AVAILABLE_LOGGING_DRIVERS=[\"json-file\",\"awslogs\"]" >> /etc/ecs/ecs.config

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Install nvidia-docker2 for GPU support
yum update -y
yum install -y docker
systemctl start docker
systemctl enable docker

# Install nvidia-container-toolkit
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

# For Amazon Linux 2
yum install -y nvidia-container-toolkit
systemctl restart docker

# Start ECS agent
systemctl start ecs
systemctl enable ecs

# Add ec2-user to docker group
usermod -a -G docker ec2-user

# Create log directory
mkdir -p /var/log/renderer-server
chown ec2-user:ec2-user /var/log/renderer-server

# Install CloudWatch agent
yum install -y amazon-cloudwatch-agent

echo "Renderer server initialization completed"