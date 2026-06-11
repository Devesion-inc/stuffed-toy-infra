
resource "aws_instance" "stuffed_toy_tts" {
  ami                    = data.aws_ami.deep_learning.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.stuffed_toy_tts.id]
  iam_instance_profile   = aws_iam_instance_profile.stuffed_toy_tts_ec2.name

  # ECR / SSM への outbound 用に Public IP を付与（EIP で固定）
  associate_public_ip_address = true

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.root_volume_size
    delete_on_termination = true
    encrypted             = true
  }

  # user_data: ECR から pull → systemd で常駐
  # SSM agent は Deep Learning AMI にプリインストール済み
  user_data = <<-EOF
    #!/bin/bash
    set -e
    exec > /var/log/user-data.log 2>&1

    REGION=ap-northeast-1
    ECR_REPO=${var.ecr_repository_url}
    IMAGE=${var.ecr_repository_url}:${var.image_tag}
    PORT=${var.container_port}

    # systemd unit を先に書く（image pull が失敗しても再試行できるように）
    cat > /etc/systemd/system/aivis.service <<'SERVICE'
    [Unit]
    Description=Aivis TTS Engine
    After=docker.service
    Requires=docker.service

    [Service]
    Restart=always
    RestartSec=30
    EnvironmentFile=/etc/aivis.env
    ExecStartPre=-/usr/bin/docker rm -f aivis
    ExecStartPre=/bin/bash -c 'aws ecr get-login-password --region $${REGION} | docker login --username AWS --password-stdin $${ECR_REGISTRY}'
    ExecStartPre=/usr/bin/docker pull $${IMAGE}
    ExecStart=/usr/bin/docker run --rm --name aivis --gpus all -p $${PORT}:$${PORT} $${IMAGE}
    ExecStop=/usr/bin/docker stop aivis

    [Install]
    WantedBy=multi-user.target
    SERVICE

    # systemd unit から参照する env
    ECR_REGISTRY=$(echo $ECR_REPO | cut -d/ -f1)
    cat > /etc/aivis.env <<EOENV
    REGION=$REGION
    ECR_REGISTRY=$ECR_REGISTRY
    IMAGE=$IMAGE
    PORT=$PORT
    EOENV

    systemctl daemon-reload
    systemctl enable --now aivis || true # image 未 push でも fail しないように
  EOF

  tags = {
    Name = "stuffed-toy-tts-${var.env_value_environment}"
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      ami, # AMI 更新時の自動再作成を防止
    ]
  }
}

# Elastic IP（停止/起動でも public IP を保持。foodex パターン踏襲）
resource "aws_eip" "stuffed_toy_tts" {
  domain = "vpc"

  tags = {
    Name = "stuffed-toy-tts-eip-${var.env_value_environment}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eip_association" "stuffed_toy_tts" {
  instance_id   = aws_instance.stuffed_toy_tts.id
  allocation_id = aws_eip.stuffed_toy_tts.id

  depends_on = [aws_instance.stuffed_toy_tts]
}
