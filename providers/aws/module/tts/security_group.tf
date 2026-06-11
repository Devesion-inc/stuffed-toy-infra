
resource "aws_security_group" "stuffed_toy_tts" {
  name        = "stuffed-toy-tts-${var.env_value_environment}"
  description = "stuffed-toy TTS EC2 security group"
  vpc_id      = var.vpc_id

  # api / relay の ECS SG からの inbound のみ許可
  dynamic "ingress" {
    for_each = var.allowed_security_group_ids
    content {
      from_port       = var.container_port
      to_port         = var.container_port
      protocol        = "tcp"
      security_groups = [ingress.value]
      description     = "Aivis TTS engine"
    }
  }

  # outbound: Docker Hub / Secrets Manager / 各種 API 用に全許可
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
