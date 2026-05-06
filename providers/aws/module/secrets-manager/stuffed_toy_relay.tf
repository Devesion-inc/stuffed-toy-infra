
resource "aws_secretsmanager_secret" "stuffed_toy_relay" {
  name = "/stuffed-toy/${var.env_value_environment}/relay"
}

resource "aws_secretsmanager_secret_version" "stuffed_toy_relay" {
  secret_id = aws_secretsmanager_secret.stuffed_toy_relay.id
  secret_string = jsonencode({
    value = "tentative_value"
  })
  lifecycle {
    ignore_changes = [
      secret_string
    ]
  }
}
