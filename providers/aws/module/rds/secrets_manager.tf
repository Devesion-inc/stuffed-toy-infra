
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
    username           = var.stuffed_toy_rds_username
    password           = random_password.stuffed_toy_db.result
    engine             = var.stuffed_toy_rds_engine
    dbname             = var.stuffed_toy_rds_name
    host               = aws_rds_cluster.stuffed_toy_db.endpoint
    port               = "5432"
    writer_endpoint    = aws_rds_cluster.stuffed_toy_db.endpoint
    reader_endpoint    = aws_rds_cluster.stuffed_toy_db.reader_endpoint
    cluster_identifier = "stuffed-toy-cluster-${var.env_value_environment}"
    sslmode            = var.stuffed_toy_rds_sslmode
  })
}
