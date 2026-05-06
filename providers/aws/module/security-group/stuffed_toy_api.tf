
resource "aws_security_group" "stuffed_toy_api_app_ecs_main" {
  name        = "stuffed-toy-api-app-ecs-main-${var.env_value_environment}"
  description = "stuffed-toy api app security group for main"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 3002
    to_port         = 3002
    protocol        = "tcp"
    security_groups = [aws_security_group.stuffed_toy_api_loadbalancer_main.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  depends_on = [
    aws_security_group.stuffed_toy_api_loadbalancer_main
  ]
}

resource "aws_security_group" "stuffed_toy_api_app_ecs_sub" {
  name        = "stuffed-toy-api-app-ecs-sub-${var.env_value_environment}"
  description = "stuffed-toy api app security group for sub"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 3002
    to_port         = 3002
    protocol        = "tcp"
    security_groups = [aws_security_group.stuffed_toy_api_loadbalancer_sub.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  depends_on = [
    aws_security_group.stuffed_toy_api_loadbalancer_sub
  ]
}
