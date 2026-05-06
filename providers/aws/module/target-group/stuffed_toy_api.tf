locals {
  env_short = {
    develop    = "dev"
    staging    = "stg"
    production = "prod"
  }
}

resource "aws_lb_target_group" "stuffed_toy_api_blue" {
  # nameは32文字を超えるとエラーになるので注意
  name        = "stuffed-toy-api-blue-${local.env_short[var.env_value_environment]}"
  port        = 8000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    interval            = 30
    path                = "/api/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
    matcher             = 200
  }
}

resource "aws_lb_target_group" "stuffed_toy_api_green" {
  # nameは32文字を超えるとエラーになるので注意
  name        = "stuffed-toy-api-green-${local.env_short[var.env_value_environment]}"
  port        = 8000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    interval            = 30
    path                = "/api/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
    matcher             = 200
  }
}
