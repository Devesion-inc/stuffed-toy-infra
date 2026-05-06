resource "aws_lb" "stuffed_toy_api" {
  # nameは32文字を超えるとエラーになるので注意
  name               = "stuffed-toy-api-lb-${var.env_value_environment}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.stuffed_toy_loadbalancer_security_groups
  subnets            = var.subnet_ids
  access_logs {
    bucket  = var.stuffed_toy_api_elb_log_aws_s3_bucket_id
    enabled = true
    prefix  = "access_logs"
  }
}

resource "aws_lb_listener" "stuffed_toy_api_main" {
  load_balancer_arn = aws_lb.stuffed_toy_api.arn
  port              = var.stuffed_toy_acm_arn != "" ? "443" : "80"
  protocol          = var.stuffed_toy_acm_arn != "" ? "HTTPS" : "HTTP"
  ssl_policy        = var.stuffed_toy_acm_arn != "" ? "ELBSecurityPolicy-TLS13-1-2-2021-06" : null
  certificate_arn   = var.stuffed_toy_acm_arn != "" ? var.stuffed_toy_acm_arn : null

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = ""
      status_code  = "403"
    }
  }
}

resource "aws_lb_listener" "stuffed_toy_api_sub" {
  load_balancer_arn = aws_lb.stuffed_toy_api.arn
  port              = var.stuffed_toy_acm_arn != "" ? "8443" : "8080"
  protocol          = var.stuffed_toy_acm_arn != "" ? "HTTPS" : "HTTP"
  ssl_policy        = var.stuffed_toy_acm_arn != "" ? "ELBSecurityPolicy-TLS13-1-2-2021-06" : null
  certificate_arn   = var.stuffed_toy_acm_arn != "" ? var.stuffed_toy_acm_arn : null

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = ""
      status_code  = "403"
    }
  }
}

resource "aws_lb_listener_rule" "stuffed_toy_api_main" {
  listener_arn = aws_lb_listener.stuffed_toy_api_main.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = var.stuffed_toy_api_blue_aws_lb_target_group_arn
  }

  condition {
    http_header {
      http_header_name = "X-Stuffed-Toy-Custom-Header"
      values           = [var.stuffed_toy_custom_header_value]
    }
  }

  lifecycle {
    ignore_changes = [
      # target_groupはBlue/Greenデプロイで動的に変更されるため
      action["target_group_arn"],
    ]
  }
}

resource "aws_lb_listener_rule" "stuffed_toy_api_sub" {
  listener_arn = aws_lb_listener.stuffed_toy_api_sub.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = var.stuffed_toy_api_green_aws_lb_target_group_arn
  }

  condition {
    http_header {
      http_header_name = "X-Stuffed-Toy-Custom-Header"
      values           = [var.stuffed_toy_custom_header_value]
    }
  }

  lifecycle {
    ignore_changes = [
      action["target_group_arn"],
    ]
  }
}
