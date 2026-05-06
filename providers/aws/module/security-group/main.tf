
# api LB
resource "aws_security_group" "stuffed_toy_api_loadbalancer_main" {
  name        = "stuffed-toy-api-loadbalancer-main-${var.env_value_environment}"
  description = "stuffed-toy api security group for main"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.lb_https_enabled ? 443 : 80
    to_port     = var.lb_https_enabled ? 443 : 80
    protocol    = "tcp"
    cidr_blocks = []
    prefix_list_ids = [
      "pl-58a04531",
    ]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "stuffed_toy_api_loadbalancer_sub" {
  name        = "stuffed-toy-api-loadbalancer-sub-${var.env_value_environment}"
  description = "stuffed-toy api security group for sub"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.lb_https_enabled ? 8443 : 8080
    to_port     = var.lb_https_enabled ? 8443 : 8080
    protocol    = "tcp"
    cidr_blocks = []
    prefix_list_ids = [
      "pl-58a04531",
    ]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# relay LB
resource "aws_security_group" "stuffed_toy_relay_loadbalancer_main" {
  name        = "stuffed-toy-relay-loadbalancer-main-${var.env_value_environment}"
  description = "stuffed-toy relay security group for main"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.lb_https_enabled ? 443 : 80
    to_port     = var.lb_https_enabled ? 443 : 80
    protocol    = "tcp"
    cidr_blocks = []
    prefix_list_ids = [
      "pl-58a04531",
    ]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "stuffed_toy_relay_loadbalancer_sub" {
  name        = "stuffed-toy-relay-loadbalancer-sub-${var.env_value_environment}"
  description = "stuffed-toy relay security group for sub"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.lb_https_enabled ? 8443 : 8080
    to_port     = var.lb_https_enabled ? 8443 : 8080
    protocol    = "tcp"
    cidr_blocks = []
    prefix_list_ids = [
      "pl-58a04531",
    ]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
