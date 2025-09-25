#!/bin/bash

# Audio Production Instance Initialization Script
# This script sets up the GPU instance for audio analysis and production

set -e

# Variables from Terraform
REGION="${region}"
PROJECT_NAME="${project_name}"
ENVIRONMENT="${environment}"

# Log output
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
echo "Starting audio production instance initialization..."
echo "Region: $REGION"
echo "Project: $PROJECT_NAME"
echo "Environment: $ENVIRONMENT"

# Update system
echo "Updating system packages..."
apt-get update -y
apt-get upgrade -y

# Install additional tools
echo "Installing additional tools..."
apt-get install -y \
    htop \
    tree \
    unzip \
    wget \
    curl \
    git \
    vim \
    ffmpeg \
    sox \
    python3-pip \
    awscli

# Install CloudWatch agent
echo "Installing CloudWatch agent..."
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
dpkg -i -E ./amazon-cloudwatch-agent.deb

# Configure CloudWatch agent
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << EOF
{
    "agent": {
        "metrics_collection_interval": 60,
        "run_as_user": "cwagent"
    },
    "logs": {
        "logs_collected": {
            "files": {
                "collect_list": [
                    {
                        "file_path": "/var/log/user-data.log",
                        "log_group_name": "/aws/ec2/audio-production",
                        "log_stream_name": "{instance_id}/user-data.log"
                    }
                ]
            }
        }
    },
    "metrics": {
        "namespace": "ECG/AudioProduction",
        "metrics_collected": {
            "cpu": {
                "measurement": [
                    "cpu_usage_idle",
                    "cpu_usage_iowait",
                    "cpu_usage_user",
                    "cpu_usage_system"
                ],
                "metrics_collection_interval": 60
            },
            "disk": {
                "measurement": [
                    "used_percent"
                ],
                "metrics_collection_interval": 60,
                "resources": [
                    "*"
                ]
            },
            "diskio": {
                "measurement": [
                    "io_time"
                ],
                "metrics_collection_interval": 60,
                "resources": [
                    "*"
                ]
            },
            "mem": {
                "measurement": [
                    "mem_used_percent"
                ],
                "metrics_collection_interval": 60
            },
            "netstat": {
                "measurement": [
                    "tcp_established",
                    "tcp_time_wait"
                ],
                "metrics_collection_interval": 60
            }
        }
    }
}
EOF

# Start CloudWatch agent
systemctl enable amazon-cloudwatch-agent
systemctl start amazon-cloudwatch-agent

# Install Docker if not already installed
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    apt-get install -y docker.io
    systemctl start docker
    systemctl enable docker
    usermod -aG docker ubuntu
fi

# Create application directory
echo "Creating application directory..."
mkdir -p /opt/audio-production
chown ubuntu:ubuntu /opt/audio-production

# Install Python dependencies for audio processing
echo "Installing Python audio processing libraries..."
pip3 install --upgrade pip
pip3 install \
    librosa \
    soundfile \
    pydub \
    scipy \
    numpy \
    matplotlib \
    jupyter \
    boto3 \
    torch \
    torchaudio \
    transformers

# Create systemd service for audio production
cat > /etc/systemd/system/audio-production.service << EOF
[Unit]
Description=ECG Audio Production Service
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/opt/audio-production
ExecStart=/usr/bin/python3 /opt/audio-production/main.py
Restart=always
RestartSec=10
Environment=AWS_REGION=$REGION
Environment=PROJECT_NAME=$PROJECT_NAME
Environment=ENVIRONMENT=$ENVIRONMENT

[Install]
WantedBy=multi-user.target
EOF

# Enable the service (but don't start it yet - application code needs to be deployed first)
systemctl daemon-reload
systemctl enable audio-production

# Set up log rotation
cat > /etc/logrotate.d/audio-production << EOF
/var/log/audio-production/*.log {
    daily
    rotate 30
    compress
    delaycompress
    missingok
    notifempty
    create 644 ubuntu ubuntu
}
EOF

# Create log directory
mkdir -p /var/log/audio-production
chown ubuntu:ubuntu /var/log/audio-production

# Configure GPU monitoring
nvidia-smi -pm 1
nvidia-smi -acp 0

# Final setup
echo "Setting up SSH access and final configurations..."
chmod 700 /home/ubuntu/.ssh || true
chown -R ubuntu:ubuntu /home/ubuntu/.ssh || true

# Signal completion
echo "Audio production instance initialization completed successfully!"
echo "Instance is ready for audio processing workloads."

# Create a status file
echo "$(date): Audio production instance initialized" > /opt/audio-production/init-status.txt
chown ubuntu:ubuntu /opt/audio-production/init-status.txt