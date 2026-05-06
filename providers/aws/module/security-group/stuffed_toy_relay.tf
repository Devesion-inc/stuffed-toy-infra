
resource "aws_security_group" "stuffed_toy_relay_ecs_main" {
  name        = "stuffed-toy-relay-ecs-main-${var.env_value_environment}"
  description = "stuffed-toy relay ecs security group for main"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 9000
    to_port         = 9000
    protocol        = "tcp"
    security_groups = [aws_security_group.stuffed_toy_relay_loadbalancer_main.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  depends_on = [
    aws_security_group.stuffed_toy_relay_loadbalancer_main
  ]
}

resource "aws_security_group" "stuffed_toy_relay_ecs_sub" {
  name        = "stuffed-toy-relay-ecs-sub-${var.env_value_environment}"
  description = "stuffed-toy relay ecs security group for sub"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 9000
    to_port         = 9000
    protocol        = "tcp"
    security_groups = [aws_security_group.stuffed_toy_relay_loadbalancer_sub.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  depends_on = [
    aws_security_group.stuffed_toy_relay_loadbalancer_sub
  ]
}
