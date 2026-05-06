
resource "aws_secretsmanager_secret" "stuffed_toy_db" {
  name = "/stuffed-toy/${var.env_value_environment}/db"
}

resource "random_password" "stuffed_toy_db" {
  length           = 41
  special          = true
  override_special = "!*+,-._"
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
  min_upper        = 1
}

resource "aws_secretsmanager_secret_version" "stuffed_toy_db" {
  secret_id = aws_secretsmanager_secret.stuffed_toy_db.id
  secret_string = jsonencode({
    username   = var.stuffed_toy_rds_username
    password   = random_password.stuffed_toy_db.result
    engine     = var.stuffed_toy_rds_engine
    dbname     = var.stuffed_toy_rds_name
    host       = aws_db_instance.stuffed_toy_db.address
    port       = "5432"
    endpoint   = aws_db_instance.stuffed_toy_db.endpoint
    identifier = aws_db_instance.stuffed_toy_db.identifier
    sslmode    = var.stuffed_toy_rds_sslmode
  })
}
