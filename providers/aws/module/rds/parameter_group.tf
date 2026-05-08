
# DBインスタンスパラメータグループ（postgres17 family）
resource "aws_db_parameter_group" "stuffed_toy" {
  name        = "stuffed-toy-db-parameter-group-${var.env_value_environment}"
  family      = "postgres17"
  description = "DB instance parameter group"

  # タイムゾーン
  parameter {
    name         = "timezone"
    value        = "Asia/Tokyo"
    apply_method = "pending-reboot"
  }

  # 1秒以上かかったクエリをログ出力（slow query 相当）
  parameter {
    name         = "log_min_duration_statement"
    value        = "1000"
    apply_method = "immediate"
  }

  # 接続/切断ログ
  parameter {
    name         = "log_connections"
    value        = "1"
    apply_method = "immediate"
  }
  parameter {
    name         = "log_disconnections"
    value        = "1"
    apply_method = "immediate"
  }

  # ロック待ちログ
  parameter {
    name         = "log_lock_waits"
    value        = "1"
    apply_method = "immediate"
  }

  # クエリ統計用拡張
  parameter {
    name         = "shared_preload_libraries"
    value        = "pg_stat_statements"
    apply_method = "pending-reboot"
  }

  # SSL/TLS 接続を強制（平文接続を拒否）
  parameter {
    name         = "rds.force_ssl"
    value        = "1"
    apply_method = "pending-reboot"
  }
}
