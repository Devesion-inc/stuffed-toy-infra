
resource "aws_security_group" "stuffed_toy_secretsmanager_endpoint" {
  name        = "stuffed-toy-secretsmanager-endpoint-${var.env_value_environment}"
  description = "stuffed-toy secretsmanager vpc endpoint security group"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    security_groups = [
      aws_security_group.stuffed_toy_api_app_ecs_main.id,
      aws_security_group.stuffed_toy_api_app_ecs_sub.id,
      aws_security_group.stuffed_toy_relay_ecs_main.id,
      aws_security_group.stuffed_toy_relay_ecs_sub.id,
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  depends_on = [
    aws_security_group.stuffed_toy_api_app_ecs_main,
    aws_security_group.stuffed_toy_api_app_ecs_sub,
    aws_security_group.stuffed_toy_relay_ecs_main,
    aws_security_group.stuffed_toy_relay_ecs_sub,
  ]
}
