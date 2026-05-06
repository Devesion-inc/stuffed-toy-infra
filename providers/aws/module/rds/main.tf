
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 6.43.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

resource "aws_db_subnet_group" "stuffed_toy_db" {
  name       = "stuffed-toy-db-subnet-group-${var.env_value_environment}"
  subnet_ids = var.subnet_ids
}

resource "aws_db_instance" "stuffed_toy_db" {
  identifier     = "stuffed-toy-instance-${var.env_value_environment}"
  engine         = var.stuffed_toy_rds_engine
  engine_version = var.stuffed_toy_rds_engine_version
  instance_class = var.stuffed_toy_rds_instance_class

  # ストレージ
  allocated_storage     = 20
  max_allocated_storage = 100 # autoscaling 上限
  storage_type          = "gp3"
  storage_encrypted     = true

  # DB
  db_name  = var.stuffed_toy_rds_name
  username = var.stuffed_toy_rds_username
  password = random_password.stuffed_toy_db.result
  port     = 5432

  # ネットワーク
  vpc_security_group_ids = var.stuffed_toy_rds_security_group_ids
  db_subnet_group_name   = aws_db_subnet_group.stuffed_toy_db.name
  parameter_group_name   = aws_db_parameter_group.stuffed_toy.name
  multi_az               = false # staging はシングル AZ でコスト削減
  publicly_accessible    = false

  # バックアップ・メンテナンス
  backup_retention_period   = 7
  backup_window             = "02:00-04:00"
  maintenance_window        = "mon:05:00-mon:05:30"
  copy_tags_to_snapshot     = true
  delete_automated_backups  = true
  skip_final_snapshot       = false
  final_snapshot_identifier = "stuffed-toy-${var.env_value_environment}-finalsnapshot"
  apply_immediately         = true

  # 認証・保護
  iam_database_authentication_enabled = true
  deletion_protection                 = true

  # 監視
  monitoring_interval                   = 60
  monitoring_role_arn                   = aws_iam_role.stuffed_toy_db_monitoring.arn
  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  # ログ（postgresql のみ）
  enabled_cloudwatch_logs_exports = ["postgresql"]

  lifecycle {
    ignore_changes = [
      engine_version,
      snapshot_identifier,
      final_snapshot_identifier,
    ]
  }

  depends_on = [
    random_password.stuffed_toy_db
  ]
}
