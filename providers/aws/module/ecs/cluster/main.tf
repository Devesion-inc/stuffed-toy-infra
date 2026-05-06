
# api / relay の両サービスを 1 クラスタで運用
resource "aws_ecs_cluster" "stuffed_toy" {
  name = "stuffed-toy-${var.env_value_environment}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}
