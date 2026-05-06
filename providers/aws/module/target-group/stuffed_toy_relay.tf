
resource "aws_lb_target_group" "stuffed_toy_relay_blue" {
  # nameは32文字を超えるとエラーになるので注意
  name        = "stuffed-toy-relay-blue-${local.env_short[var.env_value_environment]}"
  port        = 3001
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    interval            = 30
    path                = "/healthz"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
    matcher             = 200
  }
}

resource "aws_lb_target_group" "stuffed_toy_relay_green" {
  # nameは32文字を超えるとエラーになるので注意
  name        = "stuffed-toy-relay-green-${local.env_short[var.env_value_environment]}"
  port        = 3001
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    interval            = 30
    path                = "/healthz"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
    matcher             = 200
  }
}
