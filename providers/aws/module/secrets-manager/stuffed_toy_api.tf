
resource "aws_secretsmanager_secret" "stuffed_toy_api" {
  name = "/stuffed-toy/${var.env_value_environment}/api"
}

resource "aws_secretsmanager_secret_version" "stuffed_toy_api" {
  secret_id = aws_secretsmanager_secret.stuffed_toy_api.id
  secret_string = jsonencode({
    value = "tentative_value"
  })
  # 実値は AWS コンソール / CLI で更新する想定。terraform からは管理しない。
  lifecycle {
    ignore_changes = [
      secret_string
    ]
  }
}
