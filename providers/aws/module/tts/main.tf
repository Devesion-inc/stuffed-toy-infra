# TTS（Aivis 音声合成エンジン）用 EC2 + 停止/起動 Lambda

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 6.43.0"
    }
  }
}

# Deep Learning Base AMI (NVIDIA driver + Docker + nvidia-container-toolkit プリインストール)
data "aws_ami" "deep_learning" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Deep Learning Base OSS Nvidia Driver GPU AMI (Ubuntu 22.04)*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
