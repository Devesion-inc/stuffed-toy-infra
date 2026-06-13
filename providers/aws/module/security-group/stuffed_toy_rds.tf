
resource "aws_security_group" "stuffed_toy_db" {
  name        = "stuffed-toy-db-${var.env_value_environment}"
  description = "stuffed-toy db rds security group"
  vpc_id      = var.vpc_id

  # relay は DB に直接接続しないため api ECS のみ許可
  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    security_groups = [
      aws_security_group.stuffed_toy_api_app_ecs_main.id,
      aws_security_group.stuffed_toy_api_app_ecs_sub.id,
    ]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    security_groups = [
      aws_security_group.stuffed_toy_api_app_ecs_main.id,
      aws_security_group.stuffed_toy_api_app_ecs_sub.id,
    ]
  }

  depends_on = [
    aws_security_group.stuffed_toy_api_app_ecs_main,
    aws_security_group.stuffed_toy_api_app_ecs_sub,
  ]
}
